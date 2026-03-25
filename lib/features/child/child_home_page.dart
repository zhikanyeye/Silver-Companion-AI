import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/child/child_dashboard_service.dart';
import 'package:yinling_zhiban_demo/features/child/mock_family_data.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ChildHomePage extends StatefulWidget {
  const ChildHomePage({super.key, this.service = const ChildDashboardService()});

  final ChildDashboardService service;

  @override
  State<ChildHomePage> createState() => _ChildHomePageState();
}

class _ChildHomePageState extends State<ChildHomePage> {
  ChildDashboardData? _dashboardData;
  Object? _initialLoadError;
  var _isInitialLoading = true;
  var _isRefreshing = false;
  String? _refreshMessage;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void didUpdateWidget(covariant ChildHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _initialLoadError = null;
      _refreshMessage = null;
    });

    try {
      final dashboard = await widget.service.loadDashboard();
      if (!mounted) return;
      setState(() {
        _dashboardData = dashboard;
        _isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initialLoadError = error;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _reload() async {
    if (_dashboardData == null) {
      await _loadInitial();
      return;
    }

    setState(() {
      _isRefreshing = true;
      _refreshMessage = null;
    });

    try {
      final dashboard = await widget.service.loadDashboard();
      if (!mounted) return;
      setState(() {
        _dashboardData = dashboard;
        _isRefreshing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
        _refreshMessage = '刷新失败，请稍后再试';
      });
    }
  }

  void _retry() {
    _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('子女端'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: '返回首页',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(landingRoute, (route) => false),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTheme.serviceGradient,
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
                    child: _buildBody(
                      context,
                      horizontalPadding: horizontalPadding,
                      isCompact: isCompact,
                      isSplit: isSplit,
                    ),
                  ),
                );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required double horizontalPadding,
    required bool isCompact,
    required bool isSplit,
  }) {
    if (_isInitialLoading && _dashboardData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('正在整理家人近况...'),
        ),
      );
    }

    if (_initialLoadError != null && _dashboardData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 12),
              const Text('暂时无法加载家人近况'),
              const SizedBox(height: 8),
              const Text('请稍后重试。'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retry,
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

    final dashboard = _dashboardData!;

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          isCompact ? 16 : 20,
          horizontalPadding,
          24,
        ),
        children: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (_refreshMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_refreshMessage!),
              ),
            ),
          _ChildOverviewHero(metrics: dashboard.overviewMetrics),
          const SizedBox(height: 18),
          if (isSplit)
            Row(
              key: const Key('childDashboardSplit'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: _StatusPanel(items: dashboard.statusCards),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 9,
                  child: _AlertTimelinePanel(items: dashboard.alerts),
                ),
              ],
            )
          else
            Column(
              key: const Key('childDashboardStack'),
              children: [
                _StatusPanel(items: dashboard.statusCards),
                const SizedBox(height: 18),
                _AlertTimelinePanel(items: dashboard.alerts),
              ],
            ),
        ],
      ),
    );
  }
}

class _ChildOverviewHero extends StatelessWidget {
  const _ChildOverviewHero({required this.metrics});

  final List<ChildOverviewMetricData> metrics;

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDCE7FF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.priority_high_rounded, color: AppTheme.serviceBluePrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '建议优先处理',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Text('2项', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in metrics)
                _OverviewMetric(label: metric.label, value: metric.value),
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
  const _StatusPanel({required this.items});

  final List<ChildStatusCardData> items;

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
        ...items.map(
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
  const _AlertTimelinePanel({required this.items});

  final List<ChildAlertItem> items;

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
        ...items.map(
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
