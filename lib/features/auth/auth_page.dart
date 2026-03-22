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

class _AuthPageState extends State<AuthPage> {
  static const _motionDuration = Duration(milliseconds: 220);

  AuthTabSelection? _selectedTab;
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    _selectedTab ??= AuthPage.tabFromRouteArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedTab = _selectedTab ?? AuthTabSelection.login;

    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.backgroundTop, Color(0xFFFFE7D3), Colors.white],
              ),
            ),
          ),
          Positioned(
            top: -70,
            right: -30,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isCompact = width < 600;
                final isTablet = width >= 600 && width < 1100;
                final scrollPadding = EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : (isTablet ? 24 : 32),
                  vertical: isCompact ? 16 : (isTablet ? 24 : 28),
                );
                final cardPadding = EdgeInsets.all(isCompact ? 20 : (isTablet ? 24 : 28));

                return Center(
                  child: SingleChildScrollView(
                    key: const Key('authBrandShell'),
                    padding: scrollPadding,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: AnimatedSlide(
                        duration: _motionDuration,
                        curve: Curves.easeOutCubic,
                        offset: _isVisible ? Offset.zero : const Offset(0, 0.08),
                        child: AnimatedOpacity(
                          duration: _motionDuration,
                          curve: Curves.easeOut,
                          opacity: _isVisible ? 1 : 0,
                          child: Card(
                            color: AppTheme.surface,
                            child: Padding(
                              padding: cardPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E7),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: const Color(0xFFF1D3BE)),
                                    ),
                                    child: Text(
                                      '欢迎使用银龄智伴',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('银龄智伴', style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 8),
                                  Text(
                                    '完成基础信息确认后，即可选择身份并进入服务。',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 24),
                                  AuthTabs(
                                    selectedTab: selectedTab,
                                    onChanged: (tab) => setState(() => _selectedTab = tab),
                                  ),
                                  const SizedBox(height: 24),
                                  AuthForm(
                                    tab: selectedTab,
                                    onSuccess: () => Navigator.of(
                                      context,
                                    ).pushNamed(roleSelectRoute),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
