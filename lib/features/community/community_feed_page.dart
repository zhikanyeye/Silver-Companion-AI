import 'package:flutter/material.dart';

import 'package:yinling/features/community/community_feed_service.dart';
import 'package:yinling/features/community/mock_posts.dart';
import 'package:yinling/services/demo_identity_store.dart';
import 'package:yinling/theme/app_theme.dart';

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

  List<CommunityPost> get _myRespondedPosts =>
      _posts.where((post) => post.respondedByMe).toList(growable: false);

  List<CommunityPost> get _visiblePosts {
    final items = List<CommunityPost>.from(_posts);
    if (_selectedBucket == CommunityFeedBucket.latest) {
      items.sort(
        (left, right) =>
            right.createdAtEpochMs.compareTo(left.createdAtEpochMs),
      );
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

  String _friendlyErrorMessage(Object error, {required String fallback}) {
    final raw = error.toString().trim();
    if (raw.isEmpty) {
      return fallback;
    }
    if (raw.startsWith('Bad state: ')) {
      return raw.substring('Bad state: '.length).trim();
    }
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length).trim();
    }
    return raw;
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
    } catch (error) {
      final message = _friendlyErrorMessage(error, fallback: '发布失败，请稍后再试。');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = message;
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
    } catch (error) {
      final message = _friendlyErrorMessage(error, fallback: '响应失败，请稍后再试。');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('社区互助')),
      body: Container(
        key: const Key('communityServiceShell'),
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadPosts,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                const _CommunityHeroCard(),
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
                  const _EmptyFeedCard(
                    title: '暂时还没有新的社区动态',
                    subtitle: '可以切换到其他分栏，或先发布一条互助信息。',
                  )
                else
                  ..._visiblePosts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CommunityPostCard(
                        key: Key('communityPostCard_${post.id}'),
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
        label: const Text('发布互助'),
      ),
    );
  }
}

class _CommunityHeroCard extends StatelessWidget {
  const _CommunityHeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF3FF), Color(0xFFF9FCFF), Color(0xFFFFF1E8)],
        ),
        border: Border.all(color: const Color(0xFFDCE7FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102563EB),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '邻里互助广场',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.serviceBluePrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('社区互助与邻里消息', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '查看附近求助、社区公告和已发布的互助信息，也可以发起新的互助请求。',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _HeroBadge(icon: Icons.campaign_outlined, title: '社区公告'),
                _HeroBadge(
                  icon: Icons.volunteer_activism_outlined,
                  title: '邻里响应',
                ),
                _HeroBadge(icon: Icons.shield_outlined, title: '防诈提醒'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE7FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.serviceBluePrimary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
        ],
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
    final displayName = identity?.displayName ?? '邻里用户';
    final identityLabel = identity?.identityLabel ?? '社区住户';
    final theme = Theme.of(context);

    return Card(
      key: const Key('communityMySummaryCard'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$displayName · $identityLabel',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('您发布和已响应的互助信息会集中显示在这里。', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: '我发布的',
                    value: '${publishedPosts.length}',
                    valueKey: const Key('communityMyPublishedCount'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: '我响应的',
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(key: valueKey, value, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _FeedSwitcher extends StatelessWidget {
  const _FeedSwitcher({required this.selectedBucket, required this.onChanged});

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
              child: _SwitchButton(
                key: const Key('communityFeedRecommendedTab'),
                label: '推荐',
                selected: selectedBucket == CommunityFeedBucket.recommended,
                onTap: () => onChanged(CommunityFeedBucket.recommended),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SwitchButton(
                key: const Key('communityFeedLatestTab'),
                label: '最新',
                selected: selectedBucket == CommunityFeedBucket.latest,
                onTap: () => onChanged(CommunityFeedBucket.latest),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F1FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: selected
                  ? AppTheme.serviceBluePrimary
                  : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    super.key,
    required this.post,
    required this.onRespond,
  });

  final CommunityPost post;
  final VoidCallback onRespond;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    post.username.substring(0, 1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.serviceBluePrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.username, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(post.identity, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    post.tag,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.serviceBluePrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(post.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              post.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textStrong,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaChip(icon: Icons.place_outlined, label: post.location),
                _MetaChip(icon: Icons.schedule_outlined, label: post.time),
                _MetaChip(
                  icon: Icons.volunteer_activism_outlined,
                  label: post.responseStatus,
                ),
              ],
            ),
            if (post.helperNames.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '最近响应：${post.helperNames.join('、')}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 14),
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
                            Text('地点：${post.location}'),
                            const SizedBox(height: 8),
                            Text('状态：${post.responseStatus}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('关闭'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('查看详情'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    key: Key('communityRespondButton_${post.id}'),
                    onPressed: post.respondedByMe ? null : onRespond,
                    child: Text(post.respondedByMe ? '已响应' : '我来帮忙'),
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

class _EmptyFeedCard extends StatelessWidget {
  const _EmptyFeedCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.serviceBluePrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textStrong,
            ),
          ),
        ],
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

class _PublishCommunityPostDialogState
    extends State<_PublishCommunityPostDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  String _selectedTag = '求助';

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
      title: const Text('发布社区互助'),
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
                  decoration: const InputDecoration(labelText: '称呼'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('communityPublishIdentityField'),
                  controller: _identityController,
                  decoration: const InputDecoration(labelText: '身份'),
                  validator: _requiredValidator,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTag,
                  decoration: const InputDecoration(labelText: '类型'),
                  items: const [
                    DropdownMenuItem(value: '求助', child: Text('求助')),
                    DropdownMenuItem(value: '互助', child: Text('互助')),
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
                  decoration: const InputDecoration(labelText: '标题'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('communityPublishLocationField'),
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: '地点'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('communityPublishSummaryField'),
                  controller: _summaryController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: '内容说明'),
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
          child: const Text('取消'),
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
          child: const Text('发布'),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '此项不能为空';
    }
    return null;
  }
}
