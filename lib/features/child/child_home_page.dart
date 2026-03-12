import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/child/mock_family_data.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ChildHomePage extends StatelessWidget {
  const ChildHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('子女端')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundTop, Color(0xFFFFECDD)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _ChildHeroCard(
                title: '家人近况一眼安心',
                subtitle: '把今天的状态和提醒整理成更清晰的照护视图。',
              ),
              const SizedBox(height: 18),
              Text('成长状态', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                '重点信息先看到，手机上浏览也更轻松。',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ...childStatusCards.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StatusCard(item: item),
                ),
              ),
              const SizedBox(height: 6),
              Text('提醒时间线', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                '按时间顺序整理，重要提醒不会错过。',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ...childAlerts.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AlertCard(item: item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildHeroCard extends StatelessWidget {
  const _ChildHeroCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFCF8), Color(0xFFFFE6D6)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14C96A43),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.favorite_outline_rounded,
              color: AppTheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.item});

  final ChildStatusCardData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFFFFF7F1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(item.value, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.item});

  final ChildAlertItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFFFFFCF8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${item.time} ${item.title}', style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
