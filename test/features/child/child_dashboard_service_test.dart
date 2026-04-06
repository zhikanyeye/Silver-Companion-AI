import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/child/child_dashboard_service.dart';

void main() {
  test('service returns structured child dashboard data', () async {
    const service = ChildDashboardService();

    final dashboard = await service.loadDashboard();

    expect(dashboard.overviewMetrics, isNotEmpty);
    expect(dashboard.statusCards, isNotEmpty);
    expect(dashboard.alerts, isNotEmpty);
    expect(dashboard.overviewMetrics.first.label, 'Today overall');
    expect(dashboard.statusCards.first.label, 'Daily activity');
    expect(dashboard.alerts.first.title, 'Drink water reminder');
  });
}
