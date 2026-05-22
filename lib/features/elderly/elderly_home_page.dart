import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:yinling/features/elderly/mock_service_data.dart';
import 'package:yinling/routes.dart';
import 'package:yinling/theme/app_theme.dart';

class ElderlyHomePage extends StatelessWidget {
  const ElderlyHomePage({super.key});

  Future<void> _showHelpSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF7),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        var copiedMessage = '';

        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('您需要哪类帮助？', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        '平台优先帮您连到家人、社区或客服，不替代线下紧急救助。',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (copiedMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7EA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            copiedMessage,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      for (final contact in elderlySupportContacts) ...[
                        _HelpContactCard(
                          contact: contact,
                          onCopy: () {
                            Clipboard.setData(
                              ClipboardData(text: contact.phone),
                            );
                            setModalState(() {
                              copiedMessage = '联系电话已复制';
                            });
                          },
                        ),
                        if (contact != elderlySupportContacts.last)
                          const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SOSDialog(),
    );
  }

  Future<void> _showCareServiceSheet(
    BuildContext context,
    ElderlyCareService service,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF8FBFF),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        var copied = false;

        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3FF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            service.icon,
                            color: AppTheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.tag,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppTheme.serviceBluePrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(service.description, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.borderSoft),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.hub_outlined,
                            color: AppTheme.serviceBluePrimary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '银聆只提供聚合入口和转接能力，具体报价、排班和服务履约由已接入的第三方服务商完成。',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ServiceSheetLine(
                      label: '接入商',
                      value: service.providerName,
                    ),
                    _ServiceSheetLine(
                      label: '接入数量',
                      value: '${service.providerCount} 家服务商',
                    ),
                    _ServiceSheetLine(label: '覆盖范围', value: service.coverage),
                    _ServiceSheetLine(label: '联系电话', value: service.phone),
                    _ServiceSheetLine(
                      label: '转接时间',
                      value: service.serviceHours,
                    ),
                    if (copied) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7EA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '联系电话已复制',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: service.phone),
                              );
                              setModalState(() {
                                copied = true;
                              });
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: const Text('复制转接电话'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('知道了'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('长辈首页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: '返回首页',
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(landingRoute, (route) => false),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSOSDialog(context),
        backgroundColor: AppTheme.error,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.sos_rounded),
        label: const Text('紧急求助'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < 640;
              final isWide = width >= 960;
              final horizontalPadding = isCompact
                  ? 16.0
                  : (isWide ? 28.0 : 22.0);
              final sectionSpacing = isCompact ? 16.0 : 20.0;

              final services = [
                _ElderlyServiceItem(
                  key: const Key('elderlyAiCompanionEntry'),
                  title: '小灵 AI 陪伴',
                  description: '平台自有 AI 陪伴入口，继续聊天、语音播报和提醒。',
                  icon: Icons.chat_bubble_outline_rounded,
                  accent: const Color(0xFFE9F2FF),
                  iconColor: const Color(0xFF2563EB),
                  badge: '平台自有',
                  onTap: () => Navigator.of(context).pushNamed(chatRoute),
                ),
                _ElderlyServiceItem(
                  key: const Key('elderlyHelpEntry'),
                  title: '求助',
                  description: '快速连到家人、社区和平台客服，减少老人自己查找。',
                  icon: Icons.support_agent_rounded,
                  accent: const Color(0xFFFFF0E8),
                  iconColor: const Color(0xFFDA6A2A),
                  badge: '转接入口',
                  emphasize: true,
                  onTap: () => _showHelpSheet(context),
                ),
                _ElderlyServiceItem(
                  key: const Key('elderlyCommunityEntry'),
                  title: '社区',
                  description: '聚合邻里互助、社区通知和服务站消息。',
                  icon: Icons.groups_2_outlined,
                  accent: const Color(0xFFEEF7FF),
                  iconColor: const Color(0xFF1D4ED8),
                  badge: '信息聚合',
                  onTap: () => Navigator.of(context).pushNamed(communityRoute),
                ),
                _ElderlyServiceItem(
                  key: const Key('elderlyActivitiesEntry'),
                  title: '活动',
                  description: '查看社区、机构和志愿团队发布的活动。',
                  icon: Icons.event_available_outlined,
                  accent: const Color(0xFFFFF6EA),
                  iconColor: const Color(0xFFB45309),
                  badge: '机构发布',
                  onTap: () =>
                      Navigator.of(context).pushNamed(elderlyActivitiesRoute),
                ),
                for (final service in elderlyCareServices)
                  _ElderlyServiceItem(
                    key: Key('elderlyCareService${service.title}'),
                    title: service.title,
                    description: service.description,
                    icon: service.icon,
                    accent: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF1D4ED8),
                    badge: '${service.providerCount} 家接入',
                    meta: service.coverage,
                    onTap: () => _showCareServiceSheet(context, service),
                  ),
              ];

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isCompact ? 16 : 20,
                      horizontalPadding,
                      24,
                    ),
                    children: [
                      const _ServiceHallHero(),
                      SizedBox(height: sectionSpacing),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '常用服务',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '平台像便民信息集市一样聚合服务资源，老人点入口后再转接到合适服务商。',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isCompact ? 12 : 16),
                      _ElderlyServiceGrid(
                        items: services,
                        isCompact: isCompact,
                        isWide: isWide,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ServiceSheetLine extends StatelessWidget {
  const _ServiceSheetLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label, style: theme.textTheme.titleSmall),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _HelpContactCard extends StatelessWidget {
  const _HelpContactCard({required this.contact, required this.onCopy});

  final ElderlySupportContact contact;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(contact.icon, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.label, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(contact.name, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 2),
                      Text(contact.phone, style: theme.textTheme.titleSmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(contact.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('复制号码'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceHallHero extends StatelessWidget {
  const _ServiceHallHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF3FF), Color(0xFFF9FCFF), Color(0xFFFFF1E8)],
        ),
        border: Border.all(color: const Color(0xFFD8E5FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142563EB),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '第三方服务聚合广场',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFF1D4ED8),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('今天想找哪类服务？', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '银聆负责聚合服务资源、整理信息和辅助转接，家政、陪诊、助餐等服务由第三方公司或社区机构完成。',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Text('今日推荐入口', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD9E6FF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFFDA6A2A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('先选品类，再转接服务商', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '类似便民分类平台，减少老人自己查找电话和比对信息的成本。',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HallTag(label: '平台聚合'),
              _HallTag(label: '服务商履约'),
              _HallTag(label: '一键转接'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HallTag extends StatelessWidget {
  const _HallTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6FF)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _ElderlyServiceGrid extends StatelessWidget {
  const _ElderlyServiceGrid({
    required this.items,
    required this.isCompact,
    required this.isWide,
  });

  final List<_ElderlyServiceItem> items;
  final bool isCompact;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        key: const Key('elderlyServiceGridSingleColumn'),
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _ElderlyServiceCard(item: items[index]),
            if (index != items.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = isWide ? 18.0 : 16.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          key: const Key('elderlyServiceGridMultiColumn'),
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _ElderlyServiceCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _ElderlyServiceItem {
  const _ElderlyServiceItem({
    this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.iconColor,
    required this.onTap,
    this.badge,
    this.meta,
    this.emphasize = false,
  });

  final Key? key;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final Color iconColor;
  final VoidCallback onTap;
  final String? badge;
  final String? meta;
  final bool emphasize;
}

class _ElderlyServiceCard extends StatelessWidget {
  const _ElderlyServiceCard({required this.item});

  final _ElderlyServiceItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: item.key,
      elevation: item.emphasize ? 1 : 0,
      color: item.emphasize ? const Color(0xFFFFF7F0) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: item.emphasize
              ? const Color(0xFFFFC7A3)
              : const Color(0xFFD9E6F7),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: item.accent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 29),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(item.title, style: theme.textTheme.titleLarge),
                            if (item.badge != null)
                              _ServiceBadge(
                                label: item.badge!,
                                color: item.iconColor,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.meta ?? '点击查看',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    item.meta == null ? '进入' : '查看服务商',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: item.emphasize
                          ? const Color(0xFFDA6A2A)
                          : AppTheme.serviceBluePrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: item.emphasize
                        ? const Color(0xFFDA6A2A)
                        : AppTheme.serviceBluePrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  const _ServiceBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SOSDialog extends StatefulWidget {
  const _SOSDialog();

  @override
  State<_SOSDialog> createState() => _SOSDialogState();
}

class _SOSDialogState extends State<_SOSDialog> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('紧急求助已启动'),
      content: Text('将在 $_countdown 秒后发送紧急提醒，如无需发送请立即取消。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
