import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/theme/app_theme.dart';
import 'package:yinling_zhiban_demo/widgets/brand_logo.dart';

class BrandHero extends StatefulWidget {
  const BrandHero({super.key});

  @override
  State<BrandHero> createState() => _BrandHeroState();
}

class _BrandHeroState extends State<BrandHero> {
  static const _motionDuration = Duration(milliseconds: 220);

  var _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSlide(
      duration: _motionDuration,
      curve: Curves.easeOutCubic,
      offset: _isVisible ? Offset.zero : const Offset(-0.06, 0),
      child: AnimatedOpacity(
        duration: _motionDuration,
        curve: Curves.easeOut,
        opacity: _isVisible ? 1 : 0,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFCF8), Color(0xFFFFE7D3), Color(0xFFFFD8BC)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1AC96A43),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -18,
                right: -8,
                child: IgnorePointer(
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BrandLogo(variant: BrandLogoVariant.hero),
                        SizedBox(width: 12),
                        Text('银龄智伴'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '让长辈在熟悉的关怀里，获得更安心的数字陪伴。',
                    style: theme.textTheme.headlineMedium?.copyWith(height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '从 AI 虚拟家人、健康提醒到社区互助，银龄智伴把温暖陪伴与日常支持整合到同一条简单清晰的产品路径中。',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _statChip(theme, '全天候回应', '陪伴不中断'),
                      _statChip(theme, '亲情协同', '家属随时关注'),
                      _statChip(theme, '社区连接', '邻里互助更安心'),
                    ],
                  ),
                  const SizedBox(height: 28),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(ThemeData theme, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D0B7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textMuted)),
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
