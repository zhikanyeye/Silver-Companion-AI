import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.highContrast(),
      builder: (context, child) {
        final scaled = MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(AppTheme.textScale),
        );
        return MediaQuery(data: scaled, child: child ?? const SizedBox());
      },
      routes: appRoutes,
      initialRoute: '/',
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
                onTap: () {
                  Navigator.of(context).pushNamed('/elderly');
                },
                child: ListTile(
                  title: const Text('长者'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed('/elderly');
                  },
                ),
              ),
              Semantics(
                label: '选择儿童',
                button: true,
                onTap: () {
                  Navigator.of(context).pushNamed('/child');
                },
                child: ListTile(
                  title: const Text('儿童'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pushNamed('/child');
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
