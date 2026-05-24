import 'package:flutter/material.dart';

import 'package:yinling/theme/app_theme.dart';
import 'package:yinling/widgets/brand_logo.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 520;
        final isTablet = width >= 520 && width < 900;
        final containerPadding = isCompact ? 20.0 : (isTablet ? 24.0 : 28.0);
        final borderRadius = isCompact ? 26.0 : (isTablet ? 30.0 : 32.0);
        final heroTitleStyle = isCompact
            ? theme.textTheme.headlineSmall?.copyWith(height: 1.22)
            : theme.textTheme.headlineMedium?.copyWith(height: 1.2);
        final badgeGap = isCompact ? 8.0 : 10.0;
        final sectionGap = isCompact ? 20.0 : 24.0;
        final decorationSize = isCompact ? 88.0 : (isTablet ? 100.0 : 112.0);

        return AnimatedSlide(
          duration: _motionDuration,
          curve: Curves.easeOutCubic,
          offset: _isVisible ? Offset.zero : const Offset(-0.06, 0),
          child: AnimatedOpacity(
            duration: _motionDuration,
            curve: Curves.easeOut,
            opacity: _isVisible ? 1 : 0,
            child: Container(
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFCF8),
                    Color(0xFFFFE7D3),
                    Color(0xFFFFD8BC),
                  ],
                ),
                border: Border.all(color: const Color(0xFFF1D3BE)),
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
                    top: isCompact ? -10 : -18,
                    right: isCompact ? -2 : -8,
                    child: IgnorePointer(
                      child: Container(
                        width: decorationSize,
                        height: decorationSize,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 12 : 14,
                          vertical: isCompact ? 8 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFF1D3BE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BrandLogo(variant: BrandLogoVariant.hero),
                            SizedBox(width: 12),
                            Text('银聆'),
                          ],
                        ),
                      ),
                      SizedBox(height: isCompact ? 18 : 24),
                      Text('银聆——“AI+社区”养老双引擎实践者', style: heroTitleStyle),
                      SizedBox(height: isCompact ? 10 : 12),
                      Text(
                        '连接 AI 陪伴、家庭关怀、社区互助和便民服务，让日常照护更容易被看见、被响应。',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: isCompact ? 1.55 : 1.6,
                        ),
                      ),
                      SizedBox(height: sectionGap),
                      Wrap(
                        spacing: badgeGap,
                        runSpacing: badgeGap,
                        children: [
                          _StatChip(
                            title: '全天候回应',
                            subtitle: '陪伴不中断',
                            compact: isCompact,
                          ),
                          _StatChip(
                            title: '亲情协同',
                            subtitle: '家属随时关注',
                            compact: isCompact,
                          ),
                          _StatChip(
                            title: '社区连接',
                            subtitle: '邻里互助更安心',
                            compact: isCompact,
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 24 : 28),
                      Text('核心能力', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      if (isCompact)
                        Column(
                          children: const [
                            _CapabilityBadge(
                              title: 'AI陪伴',
                              subtitle: '对话、提醒与情绪记录',
                              icon: Icons.chat_bubble_rounded,
                              compact: true,
                            ),
                            SizedBox(height: 10),
                            _CapabilityBadge(
                              title: '健康提醒',
                              subtitle: '用药作息轻提醒',
                              icon: Icons.notifications_active_rounded,
                              compact: true,
                            ),
                            SizedBox(height: 10),
                            _CapabilityBadge(
                              title: '社区互助',
                              subtitle: '邻里协同更安心',
                              icon: Icons.groups_rounded,
                              compact: true,
                            ),
                          ],
                        )
                      else
                        const Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _CapabilityBadge(
                              title: 'AI陪伴',
                              subtitle: '对话、提醒与情绪记录',
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
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.title,
    required this.subtitle,
    required this.compact,
  });

  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        border: Border.all(color: const Color(0xFFF1D3BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMuted,
            ),
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
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: compact ? double.infinity : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: compact ? 0 : 148,
          maxWidth: compact ? double.infinity : 220,
        ),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(compact ? 18 : 22),
            border: Border.all(color: const Color(0xFFF1D3BE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 36 : 40,
                height: compact ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E6),
                  borderRadius: BorderRadius.circular(compact ? 12 : 14),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primary,
                  size: compact ? 18 : 20,
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
