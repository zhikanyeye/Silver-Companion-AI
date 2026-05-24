import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling/features/auth/widgets/auth_form.dart';
import 'package:yinling/features/auth/widgets/auth_tabs.dart';
import 'package:yinling/routes.dart';
import 'package:yinling/services/auth_session_store.dart';
import 'package:yinling/theme/app_theme.dart';

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
  static const _noticeDuration = Duration(seconds: 5);
  static const _noticeAnimationDuration = Duration(milliseconds: 240);
  static const _loginNoticePreferenceKey = 'auth_access_notice_seen_login';
  static const _registerNoticePreferenceKey =
      'auth_access_notice_seen_register';

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  AuthTabSelection? _selectedTab;
  AuthTabSelection? _noticeTab;
  Timer? _noticeTimer;
  final Set<AuthTabSelection> _noticeChecksInFlight = <AuthTabSelection>{};
  final AuthSessionStore _sessionStore = AuthSessionStore();

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
    _noticeTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedTab != null) {
      return;
    }

    _selectedTab = AuthPage.tabFromRouteArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
    _maybeShowTestNotice(_selectedTab!);
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
                                    'web/assets/branding/yinling-website-logo.png',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '银聆',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0C4A6E),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  '“AI+社区”养老双引擎实践者',
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
                                        onChanged: _handleTabChanged,
                                      ),
                                      const SizedBox(height: 28),
                                      AuthForm(
                                        tab: selectedTab,
                                        onSuccess: () async {
                                          await _sessionStore.markLoggedIn();
                                          if (!context.mounted) {
                                            return;
                                          }
                                          Navigator.of(
                                            context,
                                          ).pushNamed(roleSelectRoute);
                                        },
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
                    top: isCompact ? 12 : 20,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    child: IgnorePointer(
                      ignoring: _noticeTab == null,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: AnimatedSlide(
                            offset: _noticeTab == null
                                ? const Offset(0, -0.08)
                                : Offset.zero,
                            duration: _noticeAnimationDuration,
                            curve: Curves.easeOutCubic,
                            child: AnimatedOpacity(
                              opacity: _noticeTab == null ? 0 : 1,
                              duration: _noticeAnimationDuration,
                              curve: Curves.easeOut,
                              child: _noticeTab == null
                                  ? const SizedBox.shrink()
                                  : _AuthTestStageNotice(
                                      tab: _noticeTab!,
                                      onDismiss: _hideTestNotice,
                                    ),
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

  void _handleTabChanged(AuthTabSelection tab) {
    if (_selectedTab == tab) {
      return;
    }

    setState(() => _selectedTab = tab);
    _maybeShowTestNotice(tab);
  }

  Future<void> _maybeShowTestNotice(AuthTabSelection tab) async {
    if (_noticeChecksInFlight.contains(tab)) {
      return;
    }
    _noticeChecksInFlight.add(tab);

    final preferences = await SharedPreferences.getInstance();
    final preferenceKey = _noticePreferenceKey(tab);
    final hasSeenNotice = preferences.getBool(preferenceKey) ?? false;
    _noticeChecksInFlight.remove(tab);

    if (hasSeenNotice || !mounted) {
      return;
    }

    await preferences.setBool(preferenceKey, true);
    if (!mounted) {
      return;
    }

    _noticeTimer?.cancel();
    setState(() => _noticeTab = tab);
    _noticeTimer = Timer(_noticeDuration, _hideTestNotice);
  }

  void _hideTestNotice() {
    _noticeTimer?.cancel();
    _noticeTimer = null;
    if (!mounted || _noticeTab == null) {
      return;
    }
    setState(() => _noticeTab = null);
  }

  String _noticePreferenceKey(AuthTabSelection tab) {
    return switch (tab) {
      AuthTabSelection.login => _loginNoticePreferenceKey,
      AuthTabSelection.register => _registerNoticePreferenceKey,
    };
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

class _AuthTestStageNotice extends StatelessWidget {
  const _AuthTestStageNotice({required this.tab, required this.onDismiss});

  final AuthTabSelection tab;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final title = tab == AuthTabSelection.login ? '登录提示' : '注册提示';
    final message = tab == AuthTabSelection.login
        ? '填写手机号和密码即可进入，稍后可在家庭资料中继续完善信息。'
        : '先创建账号进入银聆，之后可以绑定长辈、子女和常用服务信息。';

    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title。$message',
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD7E7F6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120C4A6E),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.warningSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFB45309),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C4A6E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                tooltip: '关闭提醒',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
