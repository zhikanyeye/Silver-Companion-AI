import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeSelectorScreen(),
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
                onTap: () {},
                child: ListTile(
                  title: const Text('长者'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              Semantics(
                label: '选择儿童',
                button: true,
                onTap: () {},
                child: ListTile(
                  title: const Text('儿童'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
