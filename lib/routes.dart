import 'package:flutter/material.dart';

import 'package:yinling/features/auth/auth_page.dart';
import 'package:yinling/features/child/child_home_page.dart';
import 'package:yinling/features/chat/chat_page.dart';
import 'package:yinling/features/community/community_feed_page.dart';
import 'package:yinling/features/elderly/elderly_activities_page.dart';
import 'package:yinling/features/elderly/elderly_home_page.dart';
import 'package:yinling/features/landing/landing_page.dart';
import 'package:yinling/features/role/role_select_page.dart';
import 'package:yinling/features/settings/settings_page.dart';
import 'package:yinling/services/auth_session_store.dart';

const String landingRoute = '/';
const String authRoute = '/auth';
const String roleSelectRoute = '/role-select';
const String elderlyRoute = '/elderly';
const String childRoute = '/child';
const String platformRoute = '/platform';
const String chatRoute = '/chat';
const String communityRoute = '/community';
const String elderlyActivitiesRoute = '/elderly/activities';
const String settingsRoute = '/settings';

final Map<String, WidgetBuilder> appRoutes = {
  landingRoute: (context) => const LandingPage(),
  authRoute: (context) => const AuthPage(),
  roleSelectRoute: (context) => const _AuthGuard(child: RoleSelectPage()),
  elderlyRoute: (context) => const _AuthGuard(child: ElderlyHomePage()),
  childRoute: (context) => const _AuthGuard(child: ChildHomePage()),
  platformRoute: (context) => const _AuthGuard(child: PlatformPlaceholderPage()),
  chatRoute: (context) => const _AuthGuard(child: ChatPage()),
  communityRoute: (context) => const _AuthGuard(child: CommunityFeedPage()),
  elderlyActivitiesRoute: (context) =>
      const _AuthGuard(child: ElderlyActivitiesPage()),
  settingsRoute: (context) => const _AuthGuard(child: SettingsPage()),
};

class PlatformPlaceholderPage extends StatelessWidget {
  const PlatformPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('平台服务')),
      body: const Center(child: Text('平台服务正在准备中。')),
    );
  }
}

class _AuthGuard extends StatefulWidget {
  const _AuthGuard({required this.child});

  final Widget child;

  @override
  State<_AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<_AuthGuard> {
  final AuthSessionStore _sessionStore = AuthSessionStore();
  late final Future<bool> _isLoggedInFuture = _sessionStore.isLoggedIn();
  bool _hasRedirected = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data ?? false;
        if (!isLoggedIn) {
          if (!_hasRedirected) {
            _hasRedirected = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(landingRoute, (route) => false);
            });
          }
          return const Scaffold(body: SizedBox.shrink());
        }

        return widget.child;
      },
    );
  }
}
