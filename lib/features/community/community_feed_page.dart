import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/community/community_feed_service.dart';
import 'package:yinling_zhiban_demo/features/community/mock_posts.dart';
import 'package:yinling_zhiban_demo/services/demo_identity_store.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({
    super.key,
    this.posts = mockPosts,
    CommunityFeedService? service,
  }) : _service = service;

  final List<CommunityPost> posts;
  final CommunityFeedService? _service;

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  CommunityFeedBucket _selectedBucket = CommunityFeedBucket.recommended;
  late final CommunityFeedService _service;
  late List<CommunityPost> _posts;
  DemoIdentity? _identity;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = widget._service ?? CommunityFeedService();
    _posts = List<CommunityPost>.from(widget.posts);
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identity = await _service.loadIdentity();
    final posts = await _service.loadPosts();
    if (!mounted) {
      return;
    }

    setState(() {
      _identity = identity;
      _posts = posts;
      _isLoading = false;
    });
  }

  List<CommunityPost> get _myPublishedPosts {
    final actorId = _identity?.actorId ?? '';
    if (actorId.isEmpty) {
      return const <CommunityPost>[];
    }
    return _posts
        .where((post) => post.ownerActorId == actorId)
        .toList(growable: false);
  }

  List<CommunityPost> get _myRespondedPosts => _posts
      .where((post) => post.respondedByMe)
      .toList(growable: false);

  List<CommunityPost> get _visiblePosts {
    final items = List<CommunityPost>.from(_posts);
    if (_selectedBucket == CommunityFeedBucket.latest) {
      items.sort((left, right) => right.createdAtEpochMs.compareTo(left.createdAtEpochMs));
      return items;
    }

    items.sort((left, right) {
      final responseOrder = right.responseCount.compareTo(left.responseCount);
      if (responseOrder != 0) {
        return responseOrder;
      }
      return right.createdAtEpochMs.compareTo(left.createdAtEpochMs);
    });
    return items;
  }

  Future<void> _openPublishDialog() async {
    final draft = await showDialog<_CommunityPostDraft>(
      context: context,
      builder: (context) => const _PublishCommunityPostDialog(),
    );
    if (draft == null) {
      return;
    }

    try {
      final created = await _service.publishPost(
        username: draft.username,
        identity: draft.identity,
        tag: draft.tag,
        title: draft.title,
        location: draft.location,
        summary: draft.summary,
      );
      final identity = await _service.loadIdentity();
      if (!mounted) {
        return;
      }
      setState(() {
        _identity = identity;
        _selectedBucket = CommunityFeedBucket.latest;
        _posts = <CommunityPost>[created, ..._posts];
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Publish failed. Please verify the KV binding.';
      });
    }
  }

  Future<void> _respondToPost(CommunityPost post) async {
    if (post.respondedByMe) {
      return;
    }

    try {
      final updated = await _service.respondToPost(post.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = _posts
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Respond failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Board')),
      body: Container(
        key: const Key('communityServiceShell'),
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadPosts,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Neighborhood help board',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'View nearby requests, respond to others, or publish a new help request.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _MyCommunitySummaryCard(
                  identity: _identity,
                  publishedPosts: _myPublishedPosts,
                  respondedPosts: _myRespondedPosts,
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                _FeedSwitcher(
                  selectedBucket: _selectedBucket,
                  onChanged: (bucket) {
                    setState(() {
                      _selectedBucket = bucket;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_isLoading && _posts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_visiblePosts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No community posts yet.'),
                    ),
                  )
                else
                  ..._visiblePosts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CommunityPostCard(
                        post: post,
                        onRespond: () => _respondToPost(post),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPublishDialog,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Publish'),
      ),
    );
  }
}

class _MyCommunitySummaryCard extends StatelessWidget {
  const _MyCommunitySummaryCard({
    required this.identity,
    required this.publishedPosts,
    required this.respondedPosts,
  });

  final DemoIdentity? identity;
  final List<CommunityPost> publishedPosts;
  final List<CommunityPost> respondedPosts;

  @override
  Widget build(BuildContext context) {
    final displayName = identity?.displayName ?? 'Neighbor';
    final identityLabel = identity?.identityLabel ?? 'Resident';

    return Card(
      key: const Key('communityMySummaryCard'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$displayName · $identityLabel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Published',
                    value: '${publishedPosts.length}',
                    valueKey: const Key('communityMyPublishedCount'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Responded',
                    value: '${respondedPosts.length}',
                    valueKey: const Key('communityMyRespondedCount'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          Text(key: valueKey, value),
        ],
      ),
    );
  }
}

class _FeedSwitcher extends StatelessWidget {
  const _FeedSwitcher({
    required this.selectedBucket,
    required this.onChanged,
  });

  final CommunityFeedBucket selectedBucket;
  final ValueChanged<CommunityFeedBucket> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ChoiceChip(
                key: const Key('communityFeedRecommendedTab'),
                label: const Text('Recommended'),
                selected: selectedBucket == CommunityFeedBucket.recommended,
                onSelected: (_) => onChanged(CommunityFeedBucket.recommended),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                key: const Key('communityFeedLatestTab'),
                label: const Text('Latest'),
                selected: selectedBucket == CommunityFeedBucket.latest,
                onSelected: (_) => onChanged(CommunityFeedBucket.latest),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.onRespond,
  });

  final CommunityPost post;
  final VoidCallback onRespond;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(post.summary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(post.username)),
                Chip(label: Text(post.location)),
                Chip(label: Text(post.responseStatus)),
              ],
            ),
            if (post.helperNames.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Recent helpers: ${post.helperNames.join(', ')}'),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(post.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.summary),
                            const SizedBox(height: 12),
                            Text('Location: ${post.location}'),
                            const SizedBox(height: 8),
                            Text('Status: ${post.responseStatus}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Details'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: Key('communityRespondButton_${post.id}'),
                    onPressed: post.respondedByMe ? null : onRespond,
                    child: Text(post.respondedByMe ? 'Responded' : 'I can help'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.dangerSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message),
    );
  }
}

class _CommunityPostDraft {
  const _CommunityPostDraft({
    required this.username,
    required this.identity,
    required this.tag,
    required this.title,
    required this.location,
    required this.summary,
  });

  final String username;
  final String identity;
  final String tag;
  final String title;
  final String location;
  final String summary;
}

class _PublishCommunityPostDialog extends StatefulWidget {
  const _PublishCommunityPostDialog();

  @override
  State<_PublishCommunityPostDialog> createState() =>
      _PublishCommunityPostDialogState();
}

class _PublishCommunityPostDialogState extends State<_PublishCommunityPostDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  String _selectedTag = 'Help';

  @override
  void dispose() {
    _usernameController.dispose();
    _identityController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Publish community post'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('communityPublishNameField'),
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('communityPublishIdentityField'),
                  controller: _identityController,
                  decoration: const InputDecoration(labelText: 'Identity'),
                  validator: _requiredValidator,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTag,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'Help', child: Text('Help')),
                    DropdownMenuItem(value: 'Mutual aid', child: Text('Mutual aid')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTag = value;
                      });
                    }
                  },
                ),
                TextFormField(
                  key: const Key('communityPublishTitleField'),
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('communityPublishLocationField'),
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('communityPublishSummaryField'),
                  controller: _summaryController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Summary'),
                  validator: _requiredValidator,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          key: const Key('communityPublishSubmitButton'),
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            Navigator.of(context).pop(
              _CommunityPostDraft(
                username: _usernameController.text,
                identity: _identityController.text,
                tag: _selectedTag,
                title: _titleController.text,
                location: _locationController.text,
                summary: _summaryController.text,
              ),
            );
          },
          child: const Text('Publish'),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }
}
