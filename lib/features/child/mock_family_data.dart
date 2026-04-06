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
    ChildOverviewMetricData(label: 'Today overall', value: 'Stable'),
    ChildOverviewMetricData(label: 'Communication', value: 'Good'),
    ChildOverviewMetricData(label: 'Priority reminders', value: '2'),
  ],
  statusCards: [
    ChildStatusCardData(label: 'Daily activity', value: '82'),
    ChildStatusCardData(label: 'Mood trend', value: 'Improving'),
  ],
  alerts: [
    ChildAlertItem(time: '17:30', title: 'Drink water reminder'),
    ChildAlertItem(time: '20:00', title: 'Bedtime reading'),
  ],
);
