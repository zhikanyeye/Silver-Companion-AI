import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/child/mock_family_data.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ChildHomePage extends StatelessWidget {
  const ChildHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('子女端')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F8FF), Color(0xFFFFF4EA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < 720;
              final isSplit = width >= 820;
              final isWide = width >= 1080;
              final horizontalPadding = isCompact ? 16.0 : (isWide ? 28.0 : 22.0);

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isCompact ? 16 : 20,
                      horizontalPadding,
                      24,
                    ),
                    children: [
                      const _ChildOverviewHero(),
                      const SizedBox(height: 18),
                      if (isSplit)
                        const Row(
                          key: Key('childDashboardSplit'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 11, child: _StatusPanel()),
                            SizedBox(width: 18),
                            Expanded(flex: 9, child: _AlertTimelinePanel()),
                          ],
                        )
                      else
                        const Column(
                          key: Key('childDashboardStack'),
                          children: [
                            _StatusPanel(),
                            SizedBox(height: 18),
                            _AlertTimelinePanel(),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChildOverviewHero extends StatelessWidget {
  const _ChildOverviewHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF2FF), Color(0xFFF9FBFF), Color(0xFFFFF2E8)],
        ),
        border: Border.all(color: const Color(0xFFDCE7FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x122563EB),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '家庭关怀总览',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFF1D4ED8),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('今天的照护重点已经为您整理好。', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '先看整体状态，再看指标变化和提醒时间线，远程关怀会更有条理。',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _OverviewMetric(label: '今日整体状态', value: '稳定'),
              _OverviewMetric(label: '沟通频率', value: '良好'),
              _OverviewMetric(label: '重要提醒', value: '2条'),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('照护指标', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('优先查看今天最值得关注的状态变化。', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        ...childStatusCards.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StatusCard(item: item),
          ),
        ),
      ],
    );
  }
}

class _AlertTimelinePanel extends StatelessWidget {
  const _AlertTimelinePanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('今日提醒', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('按时间顺序整理，重要提醒不会错过。', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        ...childAlerts.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AlertCard(item: item),
          ),
        ),
      ],
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
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 6),
                  Text(item.value, style: theme.textTheme.headlineSmall),
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
    final detail = switch (item.title) {
      '按时喝水提醒' => '建议晚饭前再确认一次饮水完成情况。',
      '睡前阅读' => '适合今晚固定时间陪伴一起完成。',
      _ => '请按计划继续关注这项提醒。',
    };

    return Card(
      color: const Color(0xFFFFFCF8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                item.time,
                style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.primary),
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
                  const SizedBox(height: 4),
                  Text(detail, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
