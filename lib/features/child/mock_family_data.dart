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

const List<ChildStatusCardData> childStatusCards = [
  ChildStatusCardData(label: '今日活跃', value: '82分'),
  ChildStatusCardData(label: '情绪趋势', value: '稳定向好'),
];

const List<ChildAlertItem> childAlerts = [
  ChildAlertItem(time: '17:30', title: '按时喝水提醒'),
  ChildAlertItem(time: '20:00', title: '睡前阅读'),
];
