import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/features/child/child_home_page.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_page.dart';
import 'package:yinling_zhiban_demo/features/community/community_feed_page.dart';
import 'package:yinling_zhiban_demo/features/elderly/elderly_activities_page.dart';
import 'package:yinling_zhiban_demo/features/elderly/elderly_home_page.dart';
import 'package:yinling_zhiban_demo/features/landing/landing_page.dart';
import 'package:yinling_zhiban_demo/features/role/role_select_page.dart';
import 'package:yinling_zhiban_demo/features/settings/settings_page.dart';

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
  roleSelectRoute: (context) => const RoleSelectPage(),
  elderlyRoute: (context) => const ElderlyHomePage(),
  childRoute: (context) => const ChildHomePage(),
  platformRoute: (context) => const PlatformPlaceholderPage(),
  chatRoute: (context) => const ChatPage(),
  communityRoute: (context) => const CommunityFeedPage(),
  elderlyActivitiesRoute: (context) => const ElderlyActivitiesPage(),
  settingsRoute: (context) => const SettingsPage(),
};

class PlatformPlaceholderPage extends StatelessWidget {
  const PlatformPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform')),
      body: const Center(child: Text('Platform services are being prepared.')),
    );
  }
}
