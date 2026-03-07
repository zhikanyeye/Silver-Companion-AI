import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/app.dart';

const String homeRoute = '/';
const String elderlyRoute = '/elderly';
const String childRoute = '/child';

final Map<String, WidgetBuilder> appRoutes = {
  homeRoute: (context) => const HomeSelectorScreen(),
  elderlyRoute: (context) => const ElderlyScreen(),
  childRoute: (context) => const ChildScreen(),
};

class ElderlyScreen extends StatelessWidget {
  const ElderlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('长者服务'),
      ),
      body: const SafeArea(child: SizedBox.shrink()),
    );
  }
}

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
