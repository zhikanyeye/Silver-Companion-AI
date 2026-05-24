import 'package:flutter/material.dart';

import 'package:yinling/features/elderly/elderly_activities_service.dart';
import 'package:yinling/features/elderly/mock_service_data.dart';
import 'package:yinling/services/demo_identity_store.dart';
import 'package:yinling/theme/app_theme.dart';

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

  List<ElderlyActivityItem> get _myJoinedItems =>
      _items.where((item) => item.joinedByMe).toList(growable: false);

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
    } catch (error) {
      final message = _friendlyErrorMessage(error, fallback: '报名失败，请稍后再试。');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = message;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('活动安排')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadActivities,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const _ActivitiesHeroCard(),
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
                    title: '今日推荐',
                    subtitle: '优先显示今天可参加的活动与服务。',
                    items: _todayItems,
                    onJoin: _joinActivity,
                  ),
                  const SizedBox(height: 18),
                  _ActivitySection(
                    title: '本周活动',
                    subtitle: '提前安排更从容，也方便和家人一起商量。',
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
        label: const Text('发布活动'),
      ),
    );
  }
}

class _ActivitiesHeroCard extends StatelessWidget {
  const _ActivitiesHeroCard();

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
                '社区活动',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.serviceBluePrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('今天和本周的社区活动', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('查看活动安排，报名参加，也可以发布新的活动邀请。', style: theme.textTheme.bodyLarge),
          ],
        ),
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
    final displayName = identity?.displayName ?? '社区活动伙伴';
    final theme = Theme.of(context);

    return Card(
      key: const Key('activitiesMySummaryCard'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('您发起和已报名的活动会集中显示在这里。', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: '我发起的',
                    value: '${createdItems.length}',
                    valueKey: const Key('activitiesMyCreatedCount'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: '我报名的',
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
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
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('暂时还没有活动发布。'),
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
    final theme = Theme.of(context);

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
                _TagChip(label: item.time, background: const Color(0xFFEAF3FF)),
                _TagChip(label: item.tag, background: const Color(0xFFFFF1E7)),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(item.location, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(item.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(
              '组织方：${item.organizerName}',
              style: theme.textTheme.bodyMedium,
            ),
            if (item.participantNames.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '最近报名：${item.participantNames.join('、')}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('已报名 ${item.joinedCount} 人')),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    key: Key('activityJoinButton_${item.id}'),
                    onPressed: item.joinedByMe ? null : onJoin,
                    child: Text(item.joinedByMe ? '已报名' : '报名参加'),
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
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
  String _tag = '文娱';
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
      title: const Text('发布活动'),
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
                  decoration: const InputDecoration(labelText: '组织方'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('activityPublishTitleField'),
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '活动标题'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('activityPublishLocationField'),
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: '活动地点'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  key: const Key('activityPublishTimeField'),
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: '活动时间'),
                  validator: _requiredValidator,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _tag,
                  decoration: const InputDecoration(labelText: '活动类型'),
                  items: const [
                    DropdownMenuItem(value: '文娱', child: Text('文娱')),
                    DropdownMenuItem(value: '健康', child: Text('健康')),
                    DropdownMenuItem(value: '服务', child: Text('服务')),
                    DropdownMenuItem(value: '锻炼', child: Text('锻炼')),
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
                  decoration: const InputDecoration(labelText: '活动分组'),
                  items: const [
                    DropdownMenuItem(
                      value: ElderlyActivityGroup.today,
                      child: Text('今日推荐'),
                    ),
                    DropdownMenuItem(
                      value: ElderlyActivityGroup.weekly,
                      child: Text('本周活动'),
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
                  decoration: const InputDecoration(labelText: '活动说明'),
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
