import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class BrandHero extends StatelessWidget {
  const BrandHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF7), Color(0xFFFFE4CF)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AC96A43),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text('银龄智伴', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'AI虚拟家人 + 社区互助的智慧养老平台',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Text('核心能力', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CapabilityBadge(
                title: 'AI陪伴',
                subtitle: '暖心对话与情绪关怀',
                icon: Icons.chat_bubble_rounded,
              ),
              _CapabilityBadge(
                title: '健康提醒',
                subtitle: '用药作息轻提醒',
                icon: Icons.notifications_active_rounded,
              ),
              _CapabilityBadge(
                title: '社区互助',
                subtitle: '邻里协同更安心',
                icon: Icons.groups_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapabilityBadge extends StatelessWidget {
  const _CapabilityBadge({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 148, maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF3D1B4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textMuted, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
