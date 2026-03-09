import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_page.dart';
import 'package:yinling_zhiban_demo/features/elderly/elderly_home_page.dart';

const String homeRoute = '/';
const String elderlyRoute = '/elderly';
const String childRoute = '/child';
const String chatRoute = '/chat';

final Map<String, WidgetBuilder> appRoutes = {
  homeRoute: (context) => const HomeSelectorScreen(),
  elderlyRoute: (context) => const ElderlyHomePage(),
  childRoute: (context) => const ChildScreen(),
  chatRoute: (context) => const ChatPage(),
};

class ChildScreen extends StatelessWidget {
  const ChildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('儿童服务'),
      ),
      body: const SafeArea(child: SizedBox.shrink()),
    );
  }
}
