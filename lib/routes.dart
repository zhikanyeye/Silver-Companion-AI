import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/child/child_home_page.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_page.dart';
import 'package:yinling_zhiban_demo/features/community/community_feed_page.dart';
import 'package:yinling_zhiban_demo/features/elderly/elderly_home_page.dart';

const String homeRoute = '/';
const String elderlyRoute = '/elderly';
const String childRoute = '/child';
const String chatRoute = '/chat';
const String communityRoute = '/community';

final Map<String, WidgetBuilder> appRoutes = {
  homeRoute: (context) => const HomeSelectorScreen(),
  elderlyRoute: (context) => const ElderlyHomePage(),
  childRoute: (context) => const ChildHomePage(),
  chatRoute: (context) => const ChatPage(),
  communityRoute: (context) => const CommunityFeedPage(),
};
