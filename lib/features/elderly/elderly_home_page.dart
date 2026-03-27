import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:yinling_zhiban_demo/features/elderly/mock_service_data.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ElderlyHomePage extends StatelessWidget {
  const ElderlyHomePage({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('服务正在完善中')),
    );
  }

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
                      Text('需要哪类帮助', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        '可先联系家人或社区服务，如需产品协助也可以联系平台客服。',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (copiedMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7EA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(copiedMessage, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                      const SizedBox(height: 16),
                      for (final contact in elderlySupportContacts) ...[
                        _HelpContactCard(
                          contact: contact,
                          onCopy: () {
                            Clipboard.setData(ClipboardData(text: contact.phone));
                            setModalState(() {
                              copiedMessage = '已复制联系电话';
                            });
                          },
                        ),
                        if (contact != elderlySupportContacts.last) const SizedBox(height: 10),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.error,
          title: const Text(
            '紧急呼救已激活',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                '如果您不取消，系统将在 5 秒后自动向家属及社区网格员发送您的精确位置与求助信息！',
                style: TextStyle(color: Colors.white, fontSize: 18, height: 1.4),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.error,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('我按错了 (取消)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('老人端'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: '返回首页',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(landingRoute, (route) => false),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSOSDialog(context),
        backgroundColor: AppTheme.error,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.sos_rounded, size: 32),
        label: const Text('紧急呼救', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTheme.serviceGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < 640;
              final isWide = width >= 960;
              final horizontalPadding = isCompact ? 16.0 : (isWide ? 28.0 : 22.0);
              final sectionSpacing = isCompact ? 16.0 : 20.0;

              final services = [
                _ElderlyServiceItem(
                  title: 'AI陪伴',
                  description: '说说近况和心情，让陪伴更自然。',
                  icon: Icons.chat_bubble_outline_rounded,
                  accent: const Color(0xFFE9F2FF),
                  iconColor: const Color(0xFF2563EB),
                  onTap: () => Navigator.of(context).pushNamed(chatRoute),
                ),
                _ElderlyServiceItem(
                  title: '一键求助',
                  description: '遇到需要帮助的时候，快速联系支持。',
                  icon: Icons.support_agent_rounded,
                  accent: const Color(0xFFFFF0E8),
                  iconColor: const Color(0xFFDA6A2A),
                  emphasize: true,
                  onTap: () => _showHelpSheet(context),
                ),
                _ElderlyServiceItem(
                  title: '社区互助',
                  description: '看看邻里今天有哪些互助信息。',
                  icon: Icons.groups_2_outlined,
                  accent: const Color(0xFFEEF7FF),
                  iconColor: const Color(0xFF1D4ED8),
                  onTap: () => Navigator.of(context).pushNamed(communityRoute),
                ),
                _ElderlyServiceItem(
                  title: '活动',
                  description: '查看适合今天参加的社区活动。',
                  icon: Icons.event_available_outlined,
                  accent: const Color(0xFFFFF6EA),
                  iconColor: const Color(0xFFB45309),
                  onTap: () => Navigator.of(context).pushNamed(elderlyActivitiesRoute),
                ),
                _ElderlyServiceItem(
                  key: const Key('childAvatarEntry'),
                  title: '小灵在线',
                  description: '像家人一样陪你聊几句，也能继续进入聊天。',
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
                              '把最常用的陪伴、求助和互助入口放到更显眼的位置。',
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
          Text('您好，今天想先用哪项服务？', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '常用入口已经为您排好，想聊天、求助或看看社区信息，都能更快找到。',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Text('今日重点服务', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD9E6FF)),
            ),
            child: Text(
              '先试试 AI 陪伴和一键求助，今天常用服务已为您排在前面。',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HallTag(label: '服务更清楚'),
              _HallTag(label: '求助更显眼'),
              _HallTag(label: '家人可协同'),
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

class _ElderlyServiceCard extends StatefulWidget {
  const _ElderlyServiceCard({required this.item});

  final _ElderlyServiceItem item;

  @override
  State<_ElderlyServiceCard> createState() => _ElderlyServiceCardState();
}

class _ElderlyServiceCardState extends State<_ElderlyServiceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    // UI UX Pro Max: respect prefers-reduced-motion
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: '${item.title}: ${item.description}',
      button: true,
      child: AnimatedScale(
        scale: (!reduceMotion && _isPressed) ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Card(
          key: item.key,
          elevation: item.emphasize ? 1 : 0,
          color: item.emphasize ? const Color(0xFFFFF5EE) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              item.onTap();
              setState(() => _isPressed = false);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppTheme.minTouchTarget * 2),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: item.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 32),
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
                      size: 28,
                      color: item.emphasize ? const Color(0xFFDA6A2A) : AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
