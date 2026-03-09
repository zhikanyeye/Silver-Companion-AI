import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/child/mock_family_data.dart';

class ChildHomePage extends StatelessWidget {
  const ChildHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('儿童服务')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '成长状态',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...childStatusCards.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    title: Text(item.label),
                    subtitle: Text(item.value),
                    leading: const Icon(Icons.monitor_heart_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '提醒时间线',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...childAlerts.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(item.title),
                  subtitle: Text('${item.time} ${item.title}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
