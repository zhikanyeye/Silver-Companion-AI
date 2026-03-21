import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/child/child_dashboard_service.dart';

void main() {
  test('service returns structured child dashboard data', () async {
    const service = ChildDashboardService();

    final dashboard = await service.loadDashboard();

    expect(dashboard.overviewMetrics, isNotEmpty);
    expect(dashboard.statusCards, isNotEmpty);
    expect(dashboard.alerts, isNotEmpty);
    expect(dashboard.overviewMetrics.first.label, '今日整体状态');
    expect(dashboard.statusCards.first.label, '今日活跃');
    expect(dashboard.alerts.first.title, '按时喝水提醒');
  });
}
