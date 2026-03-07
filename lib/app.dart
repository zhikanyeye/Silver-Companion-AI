import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.highContrast(),
      builder: (context, child) {
        final baseScaler = MediaQuery.textScalerOf(context);
        final baseScale = baseScaler.scale(1.0);
        final minScale = AppTheme.textScale;
        final scaled = MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(math.max(baseScale, minScale)),
        );
        return MediaQuery(data: scaled, child: child ?? const SizedBox());
      },
      routes: appRoutes,
      initialRoute: homeRoute,
    );
  }
}

class HomeSelectorScreen extends StatelessWidget {
  const HomeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('为谁服务？'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Semantics(
                label: '选择长者',
                button: true,
                child: ListTile(
                  title: const Text('长者'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed(elderlyRoute);
                  },
                ),
              ),
              Semantics(
                label: '选择儿童',
                button: true,
                child: ListTile(
                  title: const Text('儿童'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed(childRoute);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
