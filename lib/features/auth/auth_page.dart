import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/widgets/auth_form.dart';
import 'package:yinling_zhiban_demo/features/auth/widgets/auth_tabs.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

enum AuthTabSelection { login, register }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  static AuthTabSelection tabFromRouteArguments(Object? arguments) {
    if (arguments == AuthTabSelection.register) {
      return AuthTabSelection.register;
    }
    return AuthTabSelection.login;
  }

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  AuthTabSelection? _selectedTab;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedTab ??= AuthPage.tabFromRouteArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = _selectedTab ?? AuthTabSelection.login;

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
                        vertical: isCompact ? 20 : 32,
                      ),
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideUp,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'web/assets/branding/yinling-logo-symbol.png',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '银龄智伴',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0C4A6E),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  '安心陪伴，从这里开始',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(isCompact ? 24 : 32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x08000000),
                                        blurRadius: 32,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      AuthTabs(
                                        selectedTab: selectedTab,
                                        onChanged: (tab) =>
                                            setState(() => _selectedTab = tab),
                                      ),
                                      const SizedBox(height: 28),
                                      AuthForm(
                                        tab: selectedTab,
                                        onSuccess: () => Navigator.of(
                                          context,
                                        ).pushNamed(roleSelectRoute),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _TrustBadge(
                                      icon: Icons.lock_rounded,
                                      text: '数据加密',
                                    ),
                                    _TrustBadge(
                                      icon: Icons.verified_user_rounded,
                                      text: '隐私保护',
                                    ),
                                    _TrustBadge(
                                      icon: Icons.support_agent_rounded,
                                      text: '24h 支持',
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
                      label: '返回上一页',
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
                            Icons.arrow_back_rounded,
                            color: Color(0xFF0C4A6E),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: '返回',
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

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
