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
        title: const Text('Who is this for?'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Elderly'),
          ),
          ListTile(
            title: Text('Child'),
          ),
        ],
      ),
    );
  }
}
