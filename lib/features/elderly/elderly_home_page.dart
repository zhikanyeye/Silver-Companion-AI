import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ElderlyHomePage extends StatelessWidget {
  const ElderlyHomePage({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('服务正在完善中')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('老人端')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundTop, Color(0xFFFFE8D6)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _PageIntroCard(
                title: '今天也有人陪你慢慢聊',
                subtitle: '把常用陪伴、求助和社区入口放在更顺手的位置。',
                child: Text(
                  '温暖陪伴',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('今天想做什么', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                '大字卡片更清楚，点一下就能继续熟悉的操作。',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              _ActionEntry(
                title: 'AI陪伴',
                description: '轻松说说今天的心情和想法',
                icon: Icons.forum_outlined,
                backgroundColor: const Color(0xFFFFF3E8),
                iconColor: AppTheme.primary,
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _ActionEntry(
                title: '一键求助',
                description: '需要帮忙时更快找到支持',
                icon: Icons.sos_outlined,
                backgroundColor: const Color(0xFFFFF8EF),
                iconColor: const Color(0xFFB85B42),
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _ActionEntry(
                title: '社区互助',
                description: '看看邻里正在提供哪些帮助',
                icon: Icons.groups_outlined,
                backgroundColor: const Color(0xFFFFF5F0),
                iconColor: AppTheme.accent,
                onTap: () => Navigator.of(context).pushNamed(communityRoute),
              ),
              const SizedBox(height: 12),
              _ActionEntry(
                title: '活动',
                description: '留意今天适合参与的社区活动',
                icon: Icons.celebration_outlined,
                backgroundColor: const Color(0xFFFFFBF7),
                iconColor: const Color(0xFFD18A4E),
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: '童伴聊天入口',
                button: true,
                child: Card(
                  color: const Color(0xFFFFF7F1),
                  child: InkWell(
                    key: const Key('childAvatarEntry'),
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => Navigator.of(context).pushNamed(chatRoute),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.child_care_outlined,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('小灵陪你聊聊天', style: theme.textTheme.titleLarge),
                                const SizedBox(height: 4),
                                Text(
                                  '像家人一样陪你聊聊近况，也能继续进入聊天页面。',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIntroCard extends StatelessWidget {
  const _PageIntroCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFCF8), Color(0xFFFFE7D3)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14C96A43),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          const SizedBox(height: 10),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ActionEntry extends StatelessWidget {
  const _ActionEntry({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
