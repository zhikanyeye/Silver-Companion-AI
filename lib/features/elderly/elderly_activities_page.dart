import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/elderly/elderly_activities_service.dart';
import 'package:yinling_zhiban_demo/features/elderly/mock_service_data.dart';
import 'package:yinling_zhiban_demo/services/demo_identity_store.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ElderlyActivitiesPage extends StatefulWidget {
  const ElderlyActivitiesPage({super.key, ElderlyActivitiesService? service})
    : _service = service;

  final ElderlyActivitiesService? _service;

  @override
  State<ElderlyActivitiesPage> createState() => _ElderlyActivitiesPageState();
}

class _ElderlyActivitiesPageState extends State<ElderlyActivitiesPage> {
  late final ElderlyActivitiesService _service;
  DemoIdentity? _identity;
  List<ElderlyActivityItem> _items = <ElderlyActivityItem>[
    ...todayRecommendedActivities,
    ...weeklyActivities,
  ];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = widget._service ?? ElderlyActivitiesService();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identity = await _service.loadIdentity();
    final activities = await _service.loadActivities();
    if (!mounted) {
      return;
    }

    setState(() {
      _identity = identity;
      _items = activities;
      _isLoading = false;
    });
  }

  List<ElderlyActivityItem> get _todayItems => _items
      .where((item) => item.group == ElderlyActivityGroup.today)
      .toList(growable: false);

  List<ElderlyActivityItem> get _weeklyItems => _items
      .where((item) => item.group == ElderlyActivityGroup.weekly)
      .toList(growable: false);

  List<ElderlyActivityItem> get _myCreatedItems {
    final actorId = _identity?.actorId ?? '';
    if (actorId.isEmpty) {
      return const <ElderlyActivityItem>[];
    }
    return _items
        .where((item) => item.organizerActorId == actorId)
        .toList(growable: false);
  }

  List<ElderlyActivityItem> get _myJoinedItems => _items
      .where((item) => item.joinedByMe)
      .toList(growable: false);

  Future<void> _joinActivity(ElderlyActivityItem item) async {
    if (item.joinedByMe) {
      return;
    }

    try {
      final updated = await _service.joinActivity(item.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _items = _items
            .map((entry) => entry.id == updated.id ? updated : entry)
            .toList(growable: false);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Join failed. Please try again.';
      });
    }
  }

  Future<void> _publishActivity() async {
    final draft = await showDialog<_ActivityDraft>(
      context: context,
      builder: (context) => const _PublishActivityDialog(),
    );
    if (draft == null) {
      return;
    }

    try {
      final created = await _service.publishActivity(
        organizerName: draft.organizerName,
        title: draft.title,
        location: draft.location,
        description: draft.description,
        tag: draft.tag,
        time: draft.time,
        group: draft.group,
      );
      final identity = await _service.loadIdentity();
      if (!mounted) {
        return;
      }
      setState(() {
        _identity = identity;
        _items = <ElderlyActivityItem>[created, ..._items];
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Publish failed. Please verify the service configuration.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Schedule')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadActivities,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community activities',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Review today and this week, join an activity, or publish a new one.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _MyActivitiesSummaryCard(
                  identity: _identity,
                  createdItems: _myCreatedItems,
                  joinedItems: _myJoinedItems,
                ),
                const SizedBox(height: 18),
                if (_errorMessage != null) ...[
                  _ActivitiesErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 18),
                ],
                if (_isLoading && _items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else ...[
                  _ActivitySection(
                    title: 'Today',
                    subtitle: 'Activities you can join right away.',
                    items: _todayItems,
                    onJoin: _joinActivity,
                  ),
                  const SizedBox(height: 18),
                  _ActivitySection(
                    title: 'This week',
                    subtitle: 'Activities you can plan for in advance.',
                    items: _weeklyItems,
                    onJoin: _joinActivity,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _publishActivity,
        icon: const Icon(Icons.event_available_outlined),
        label: const Text('Publish'),
      ),
    );
  }
}

class _MyActivitiesSummaryCard extends StatelessWidget {
  const _MyActivitiesSummaryCard({
    required this.identity,
    required this.createdItems,
    required this.joinedItems,
  });

  final DemoIdentity? identity;
  final List<ElderlyActivityItem> createdItems;
  final List<ElderlyActivityItem> joinedItems;

  @override
  Widget build(BuildContext context) {
    final displayName = identity?.displayName ?? 'Community partner';

    return Card(
      key: const Key('activitiesMySummaryCard'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Created',
                    value: '${createdItems.length}',
                    valueKey: const Key('activitiesMyCreatedCount'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Joined',
                    value: '${joinedItems.length}',
                    valueKey: const Key('activitiesMyJoinedCount'),
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
        color: const Color(0xFFFFF7F0),
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

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onJoin,
  });

  final String title;
  final String subtitle;
  final List<ElderlyActivityItem> items;
  final ValueChanged<ElderlyActivityItem> onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(subtitle),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No activities published yet.'),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityCard(item: item, onJoin: () => onJoin(item)),
            ),
          ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item, required this.onJoin});

  final ElderlyActivityItem item;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(item.time)),
                Chip(label: Text(item.tag)),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(item.location),
            const SizedBox(height: 6),
            Text(item.description),
            const SizedBox(height: 12),
            Text('Organizer: ${item.organizerName}'),
            if (item.participantNames.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Recent joins: ${item.participantNames.join(', ')}'),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('Joined ${item.joinedCount}')),
                SizedBox(
                  width: 112,
                  child: ElevatedButton(
                    key: Key('activityJoinButton_${item.id}'),
                    onPressed: item.joinedByMe ? null : onJoin,
                    child: Text(item.joinedByMe ? 'Joined' : 'Join'),
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

class _ActivitiesErrorBanner extends StatelessWidget {
  const _ActivitiesErrorBanner({required this.message});

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

class _ActivityDraft {
  const _ActivityDraft({
    required this.organizerName,
    required this.title,
    required this.location,
    required this.description,
    required this.tag,
    required this.time,
    required this.group,
  });

  final String organizerName;
  final String title;
  final String location;
  final String description;
  final String tag;
  final String time;
  final ElderlyActivityGroup group;
}

class _PublishActivityDialog extends StatefulWidget {
  const _PublishActivityDialog();

  @override
  State<_PublishActivityDialog> createState() => _PublishActivityDialogState();
}

class _PublishActivityDialogState extends State<_PublishActivityDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String _tag = 'Culture';
  ElderlyActivityGroup _group = ElderlyActivityGroup.weekly;

  @override
  void dispose() {
    _organizerController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Publish activity'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('activityPublishOrganizerField'),
                  controller: _organizerController,
                  decoration: const InputDecoration(labelText: 'Organizer'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('activityPublishTitleField'),
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('activityPublishLocationField'),
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('activityPublishTimeField'),
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'Time'),
                  validator: _requiredValidator,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _tag,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'Culture', child: Text('Culture')),
                    DropdownMenuItem(value: 'Health', child: Text('Health')),
                    DropdownMenuItem(value: 'Service', child: Text('Service')),
                    DropdownMenuItem(value: 'Exercise', child: Text('Exercise')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _tag = value;
                      });
                    }
                  },
                ),
                DropdownButtonFormField<ElderlyActivityGroup>(
                  initialValue: _group,
                  decoration: const InputDecoration(labelText: 'Group'),
                  items: const [
                    DropdownMenuItem(
                      value: ElderlyActivityGroup.today,
                      child: Text('Today'),
                    ),
                    DropdownMenuItem(
                      value: ElderlyActivityGroup.weekly,
                      child: Text('This week'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _group = value;
                      });
                    }
                  },
                ),
                TextFormField(
                  key: const Key('activityPublishDescriptionField'),
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description'),
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
          key: const Key('activityPublishSubmitButton'),
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            Navigator.of(context).pop(
              _ActivityDraft(
                organizerName: _organizerController.text,
                title: _titleController.text,
                location: _locationController.text,
                description: _descriptionController.text,
                tag: _tag,
                time: _timeController.text,
                group: _group,
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
