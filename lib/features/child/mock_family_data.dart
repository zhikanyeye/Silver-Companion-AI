class ChildOverviewMetricData {
  const ChildOverviewMetricData({required this.label, required this.value});

  final String label;
  final String value;
}

class ChildStatusCardData {
  const ChildStatusCardData({required this.label, required this.value});

  final String label;
  final String value;
}

class ChildAlertItem {
  const ChildAlertItem({required this.time, required this.title});

  final String time;
  final String title;
}

class ChildDashboardData {
  const ChildDashboardData({
    required this.overviewMetrics,
    required this.statusCards,
    required this.alerts,
  });

  final List<ChildOverviewMetricData> overviewMetrics;
  final List<ChildStatusCardData> statusCards;
  final List<ChildAlertItem> alerts;
}

const ChildDashboardData mockChildDashboardData = ChildDashboardData(
  overviewMetrics: [
    ChildOverviewMetricData(label: '今日整体状态', value: '稳定'),
    ChildOverviewMetricData(label: '沟通频率', value: '良好'),
    ChildOverviewMetricData(label: '重要提醒', value: '2条'),
  ],
  statusCards: [
    ChildStatusCardData(label: '今日活跃', value: '82分'),
    ChildStatusCardData(label: '情绪趋势', value: '稳定向好'),
  ],
  alerts: [
    ChildAlertItem(time: '17:30', title: '按时喝水提醒'),
    ChildAlertItem(time: '20:00', title: '睡前阅读'),
  ],
);
