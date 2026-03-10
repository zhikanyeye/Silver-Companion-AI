import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/child/child_home_page.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_page.dart';
import 'package:yinling_zhiban_demo/features/community/community_feed_page.dart';
import 'package:yinling_zhiban_demo/features/elderly/elderly_home_page.dart';
import 'package:yinling_zhiban_demo/features/settings/settings_page.dart';

const String homeRoute = '/';
const String elderlyRoute = '/elderly';
const String childRoute = '/child';
const String platformRoute = '/platform';
const String chatRoute = '/chat';
const String communityRoute = '/community';
const String settingsRoute = '/settings';

final Map<String, WidgetBuilder> appRoutes = {
  homeRoute: (context) => const HomeSelectorScreen(),
  elderlyRoute: (context) => const ElderlyHomePage(),
  childRoute: (context) => const ChildHomePage(),
  platformRoute: (context) => const _PlatformPlaceholderPage(),
  chatRoute: (context) => const ChatPage(),
  communityRoute: (context) => const CommunityFeedPage(),
  settingsRoute: (context) => const SettingsPage(),
};

class _PlatformPlaceholderPage extends StatelessWidget {
  const _PlatformPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('平台端')),
      body: const Center(child: Text('平台端演示功能即将开放')),
    );
  }
}
