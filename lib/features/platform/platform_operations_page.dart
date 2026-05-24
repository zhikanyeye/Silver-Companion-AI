import 'package:flutter/material.dart';

import 'package:yinling/theme/app_theme.dart';

class PlatformOperationsPage extends StatelessWidget {
  const PlatformOperationsPage({super.key});

  static const List<_PlatformMetric> _metrics = <_PlatformMetric>[
    _PlatformMetric(
      label: '待分派需求',
      value: '18',
      hint: '平均 6 分钟内处理',
      icon: Icons.assignment_outlined,
      color: Color(0xFF2563EB),
    ),
    _PlatformMetric(
      label: '在线服务商',
      value: '36',
      hint: '覆盖 4 类服务',
      icon: Icons.storefront_outlined,
      color: Color(0xFF059669),
    ),
    _PlatformMetric(
      label: '今日已转接',
      value: '124',
      hint: '履约完成率 96%',
      icon: Icons.hub_outlined,
      color: Color(0xFFD97706),
    ),
    _PlatformMetric(
      label: '需回访订单',
      value: '7',
      hint: '优先关注高龄用户',
      icon: Icons.phone_in_talk_outlined,
      color: Color(0xFFDC2626),
    ),
  ];

  static const List<_ProviderCategory> _categories = <_ProviderCategory>[
    _ProviderCategory(
      title: '家政上门',
      providers: '12 家接入',
      response: '最快 15 分钟响应',
      status: '资质齐全',
      icon: Icons.cleaning_services_rounded,
    ),
    _ProviderCategory(
      title: '医疗陪诊',
      providers: '8 家接入',
      response: '支持家属确认',
      status: '需人工复核',
      icon: Icons.medical_services_rounded,
    ),
    _ProviderCategory(
      title: '助餐送餐',
      providers: '6 家接入',
      response: '午餐高峰排队中',
      status: '配送稳定',
      icon: Icons.restaurant_rounded,
    ),
    _ProviderCategory(
      title: '代买代办',
      providers: '10 家接入',
      response: '附近生活圈覆盖',
      status: '价格透明',
      icon: Icons.shopping_bag_rounded,
    ),
  ];

  static const List<_WorkOrder> _orders = <_WorkOrder>[
    _WorkOrder(
      name: '张阿姨',
      service: '家政上门',
      detail: '独居老人，优先匹配女性服务人员',
      status: '待服务商确认',
    ),
    _WorkOrder(
      name: '李先生',
      service: '医疗陪诊',
      detail: '明早复诊，子女已授权电话确认',
      status: '运营复核中',
    ),
    _WorkOrder(
      name: '王叔叔',
      service: '助餐送餐',
      detail: '低盐餐备注已同步给助餐点',
      status: '已完成转接',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('运营工作台')),
      body: Container(
        key: const Key('platformOperationsShell'),
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 720;
              final horizontalPadding = isCompact ? 16.0 : 24.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isCompact ? 16 : 22,
                      horizontalPadding,
                      32,
                    ),
                    children: [
                      const _OperationsHero(),
                      const SizedBox(height: 18),
                      _MetricGrid(metrics: _metrics, isCompact: isCompact),
                      const SizedBox(height: 18),
                      _SectionHeader(
                        title: '服务商接入',
                        subtitle: '查看服务商资质、响应状态和转接进度。',
                      ),
                      const SizedBox(height: 12),
                      _CategoryGrid(
                        categories: _categories,
                        isCompact: isCompact,
                      ),
                      const SizedBox(height: 18),
                      _SectionHeader(
                        title: '今日转接队列',
                        subtitle: '优先处理高龄、独居和需要家属确认的需求。',
                      ),
                      const SizedBox(height: 12),
                      for (final order in _orders) ...[
                        _WorkOrderCard(order: order),
                        if (order != _orders.last) const SizedBox(height: 10),
                      ],
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

class _OperationsHero extends StatelessWidget {
  const _OperationsHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E6F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '平台聚合运营',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.serviceBluePrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('把长辈需求分派给合适的服务方', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '集中查看待处理需求、服务方状态和回访任务，确保每一次转接都有跟进记录。',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics, required this.isCompact});

  final List<_PlatformMetric> metrics;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        children: [
          for (final metric in metrics) ...[
            _MetricCard(metric: metric),
            if (metric != metrics.last) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final metric in metrics)
          SizedBox(width: 265, child: _MetricCard(metric: metric)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _PlatformMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: metric.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(metric.icon, color: metric.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metric.label, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(metric.value, style: theme.textTheme.headlineMedium),
                  Text(metric.hint, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.isCompact});

  final List<_ProviderCategory> categories;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        children: [
          for (final category in categories) ...[
            _CategoryCard(category: category),
            if (category != categories.last) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final width = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final category in categories)
              SizedBox(
                width: width,
                child: _CategoryCard(category: category),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final _ProviderCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(category.icon, color: AppTheme.serviceBluePrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(category.providers, style: theme.textTheme.bodyMedium),
                  Text(category.response, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    category.status,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.serviceBluePrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkOrderCard extends StatelessWidget {
  const _WorkOrderCard({required this.order});

  final _WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.radio_button_checked_rounded,
              color: AppTheme.serviceBluePrimary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.name} · ${order.service}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(order.detail, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              order.status,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformMetric {
  const _PlatformMetric({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final Color color;
}

class _ProviderCategory {
  const _ProviderCategory({
    required this.title,
    required this.providers,
    required this.response,
    required this.status,
    required this.icon,
  });

  final String title;
  final String providers;
  final String response;
  final String status;
  final IconData icon;
}

class _WorkOrder {
  const _WorkOrder({
    required this.name,
    required this.service,
    required this.detail,
    required this.status,
  });

  final String name;
  final String service;
  final String detail;
  final String status;
}
