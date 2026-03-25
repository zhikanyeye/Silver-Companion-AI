import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/elderly/mock_service_data.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ElderlyActivitiesPage extends StatelessWidget {
  const ElderlyActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('活动安排')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.serviceGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              const _ActivitiesIntroCard(),
              const SizedBox(height: 18),
              _ActivitySection(
                title: '今日推荐',
                subtitle: '优先看看今天就能参加的活动与服务。',
                items: todayRecommendedActivities,
              ),
              const SizedBox(height: 18),
              _ActivitySection(
                title: '本周活动',
                subtitle: '提前安排更从容，也方便和家人一起商量。',
                items: weeklyActivities,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivitiesIntroCard extends StatelessWidget {
  const _ActivitiesIntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xFFFFFCF8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text('活动安排', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '把今天和本周适合参与的社区活动整理在一起，方便按时间查看。',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<ElderlyActivityItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        for (var index = 0; index < items.length; index++) ...[
          _ActivityCard(item: items[index]),
          if (index != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final ElderlyActivityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('活动详情'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(item.location, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(item.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('我知道了'),
                  ),
                ],
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      item.time,
                      style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(item.tag, style: theme.textTheme.labelLarge),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(item.location, style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(item.description, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
