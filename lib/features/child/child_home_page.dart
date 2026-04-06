import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/child/child_dashboard_charts.dart';
import 'package:yinling_zhiban_demo/features/child/child_dashboard_service.dart';
import 'package:yinling_zhiban_demo/features/child/mock_family_data.dart';
import 'package:yinling_zhiban_demo/routes.dart';
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
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
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
      if (!mounted) {
        return;
      }
      setState(() {
        _dashboardData = dashboard;
        _isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
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
      if (!mounted) {
        return;
      }
      setState(() {
        _dashboardData = dashboard;
        _isRefreshing = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRefreshing = false;
        _refreshMessage = '刷新失败，请稍后再试。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('子女看护看板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              landingRoute,
              (route) => false,
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < 720;
              final isSplit = width >= 820;
              final horizontalPadding = isCompact ? 16.0 : 22.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: _buildBody(
                    context,
                    horizontalPadding: horizontalPadding,
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
    required bool isSplit,
  }) {
    if (_isInitialLoading && _dashboardData == null) {
      return const Center(
        key: Key('childDashboardLoading'),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('正在加载家庭状态...'),
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
              const Icon(Icons.cloud_off_rounded, size: 42),
              const SizedBox(height: 12),
              const Text('暂时无法加载家庭状态'),
              const SizedBox(height: 8),
              const Text('请稍后再试。'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitial,
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
        padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
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
          const WeeklyTrendChart(),
          const SizedBox(height: 18),
          const HealthMetricsTable(),
          const SizedBox(height: 18),
          if (isSplit)
            Row(
              key: const Key('childDashboardSplit'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 11, child: _StatusPanel(items: dashboard.statusCards)),
                const SizedBox(width: 18),
                Expanded(flex: 9, child: _AlertTimelinePanel(items: dashboard.alerts)),
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
    return Container(
      key: const Key('childOverviewHero'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF2FF), Color(0xFFF9FBFF), Color(0xFFFFF2E8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '家庭照护总览',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            '今日照护重点已为您汇总，一目了然。',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in metrics)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(metric.label),
                      const SizedBox(height: 4),
                      Text(metric.value),
                    ],
                  ),
                ),
            ],
          ),
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
    return Column(
      key: const Key('childStatusPanel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('照护指标', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text('查看今天最重要的变化。'),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                title: Text(item.label),
                subtitle: Text(item.value),
              ),
            ),
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
    return Column(
      key: const Key('childAlertPanel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('今日提醒', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text('按时间线展示提醒，不错过重要事项。'),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.time),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
