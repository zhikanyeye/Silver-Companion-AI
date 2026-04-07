import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:yinling_zhiban_demo/features/elderly/mock_service_data.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

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
                        '可先联系家人或社区服务，如需产品协助也可以联系平台客服。',
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
                  title: 'AI陪伴',
                  description: '说说近况和心情，让陪伴更自然。',
                  icon: Icons.chat_bubble_outline_rounded,
                  accent: const Color(0xFFE9F2FF),
                  iconColor: const Color(0xFF2563EB),
                  onTap: () => Navigator.of(context).pushNamed(chatRoute),
                ),
                _ElderlyServiceItem(
                  key: const Key('elderlyHelpEntry'),
                  title: '求助',
                  description: '遇到需要帮助的时候，快速联系支持。',
                  icon: Icons.support_agent_rounded,
                  accent: const Color(0xFFFFF0E8),
                  iconColor: const Color(0xFFDA6A2A),
                  emphasize: true,
                  onTap: () => _showHelpSheet(context),
                ),
                _ElderlyServiceItem(
                  key: const Key('elderlyCommunityEntry'),
                  title: '社区',
                  description: '看看邻里今天有哪些互助信息。',
                  icon: Icons.groups_2_outlined,
                  accent: const Color(0xFFEEF7FF),
                  iconColor: const Color(0xFF1D4ED8),
                  onTap: () => Navigator.of(context).pushNamed(communityRoute),
                ),
                _ElderlyServiceItem(
                  key: const Key('elderlyActivitiesEntry'),
                  title: '活动',
                  description: '查看适合今天参加的社区活动。',
                  icon: Icons.event_available_outlined,
                  accent: const Color(0xFFFFF6EA),
                  iconColor: const Color(0xFFB45309),
                  onTap: () =>
                      Navigator.of(context).pushNamed(elderlyActivitiesRoute),
                ),
                _ElderlyServiceItem(
                  key: const Key('childAvatarEntry'),
                  title: '小灵在线',
                  description: '像家人一样陪您聊几句，也能继续进入聊天。',
                  icon: Icons.child_care_outlined,
                  accent: const Color(0xFFEAF3FF),
                  iconColor: const Color(0xFF2563EB),
                  onTap: () => Navigator.of(context).pushNamed(chatRoute),
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
                              '把最常用的陪伴、求助和社区入口放到更显眼的位置。',
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
              '今日服务大厅',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFF1D4ED8),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('今天想先使用哪项服务？', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '聊天、求助、社区和活动入口都已经整理好，点击更直接，辨认也更轻松。',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Text('今日重点服务', style: theme.textTheme.titleMedium),
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
                      Text('建议优先熟悉求助入口', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '需要帮助时可以更快联系家人、社区或平台支持。',
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
              _HallTag(label: '字更清楚'),
              _HallTag(label: '入口更直观'),
              _HallTag(label: '操作更轻松'),
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
    this.emphasize = false,
  });

  final Key? key;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final Color iconColor;
  final VoidCallback onTap;
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
      color: item.emphasize ? const Color(0xFFFFF5EE) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: item.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(item.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: item.emphasize
                    ? const Color(0xFFDA6A2A)
                    : AppTheme.primary,
              ),
            ],
          ),
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
