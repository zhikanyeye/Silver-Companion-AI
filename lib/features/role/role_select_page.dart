import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/role/widgets/role_option_card.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';
import 'package:yinling_zhiban_demo/widgets/brand_logo.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9FF), Color(0xFFFFF4EA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < 600;
              final horizontalPadding = isCompact ? 20.0 : 32.0;

              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: isCompact ? 24 : 40,
                      ),
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideUp,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0369A1,
                                    ).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: BrandLogo(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  '选择您的身份',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0C4A6E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '我们将为您打开专属的服务入口',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 36),
                                RoleOptionCard(
                                  title: '我是长辈',
                                  subtitle: '语音陪伴 · 健康提醒 · 社区互助',
                                  icon: Icons.elderly_rounded,
                                  iconColor: const Color(0xFFD97706),
                                  iconBg: const Color(0xFFFEF3C7),
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushNamed(elderlyRoute),
                                ),
                                const SizedBox(height: 16),
                                RoleOptionCard(
                                  title: '我是子女',
                                  subtitle: '远程关怀 · 健康看板 · 提醒管理',
                                  icon: Icons.family_restroom_rounded,
                                  iconColor: const Color(0xFF2563EB),
                                  iconBg: const Color(0xFFEFF6FF),
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushNamed(childRoute),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(color: Color(0xFFE2E8F0)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        '随时可以切换',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(color: Color(0xFFE2E8F0)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Semantics(
                      label: '退出登录',
                      button: true,
                      child: Container(
                        width: AppTheme.minTouchTarget,
                        height: AppTheme.minTouchTarget,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFF0C4A6E),
                          ),
                          tooltip: '退出登录',
                          onPressed: () =>
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                landingRoute,
                                (route) => false,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
