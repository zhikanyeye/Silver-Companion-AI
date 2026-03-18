import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';
import 'package:yinling_zhiban_demo/widgets/brand_hero.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
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
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundTop, Color(0xFFFFE7D3), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              final horizontalPadding = isWide ? 32.0 : 20.0;
              final topPadding = isWide ? 24.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (topPadding + 28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSlide(
                        duration: _motionDuration,
                        curve: Curves.easeOutCubic,
                        offset: _isVisible ? Offset.zero : const Offset(0, -0.08),
                        child: AnimatedOpacity(
                          duration: _motionDuration,
                          curve: Curves.easeOut,
                          opacity: _isVisible ? 1 : 0,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pushNamed(
                                    authRoute,
                                    arguments: AuthTabSelection.login,
                                  ),
                                  child: const Text('登录'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pushNamed(
                                    authRoute,
                                    arguments: AuthTabSelection.register,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.surface,
                                    foregroundColor: AppTheme.accent,
                                  ),
                                  child: const Text('注册'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isWide ? 28 : 22),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Expanded(flex: 11, child: BrandHero()),
                                    SizedBox(width: 24),
                                    Expanded(
                                      flex: 7,
                                      child: AnimatedSlide(
                                        duration: _motionDuration,
                                        curve: Curves.easeOutCubic,
                                        offset: _isVisible
                                            ? Offset.zero
                                            : const Offset(0.08, 0),
                                        child: AnimatedOpacity(
                                          duration: _motionDuration,
                                          curve: Curves.easeOut,
                                          opacity: _isVisible ? 1 : 0,
                                          child: const _HeroSupportPanel(),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const BrandHero(),
                                    const SizedBox(height: 18),
                                    AnimatedSlide(
                                      duration: _motionDuration,
                                      curve: Curves.easeOutCubic,
                                      offset: _isVisible
                                          ? Offset.zero
                                          : const Offset(0, 0.08),
                                      child: AnimatedOpacity(
                                        duration: _motionDuration,
                                        curve: Curves.easeOut,
                                        opacity: _isVisible ? 1 : 0,
                                        child: const _HeroSupportPanel(),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
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

class _HeroSupportPanel extends StatelessWidget {
  const _HeroSupportPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF3D2BC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('更简单地开始陪伴', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            '从首次访问到开始使用，流程更清晰，让长辈与家人都能更快进入服务。',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          const _SupportPoint(
            title: '安心开始',
            detail: '以清晰的信息和熟悉的关怀，帮助您更安心地开始使用。',
          ),
          const SizedBox(height: 14),
          const _SupportPoint(
            title: '一步完成',
            detail: '登录和注册都在同一入口完成，减少来回跳转，让长辈和家人都更容易上手。',
          ),
        ],
      ),
    );
  }
}

class _SupportPoint extends StatelessWidget {
  const _SupportPoint({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: AppTheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(detail, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
