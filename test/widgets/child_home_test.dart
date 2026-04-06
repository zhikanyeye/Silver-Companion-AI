import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/child/child_dashboard_charts.dart';
import 'package:yinling_zhiban_demo/features/child/child_dashboard_service.dart';
import 'package:yinling_zhiban_demo/features/child/child_home_page.dart';
import 'package:yinling_zhiban_demo/features/child/mock_family_data.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class _DelayedChildDashboardService extends ChildDashboardService {
  const _DelayedChildDashboardService();

  @override
  Future<ChildDashboardData> loadDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockChildDashboardData;
  }
}

void main() {
  testWidgets('child route shows dashboard structure after loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: const ChildHomePage(service: _DelayedChildDashboardService()),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byKey(const Key('childDashboardLoading')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('childOverviewHero')), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(WeeklyTrendChart, skipOffstage: false), findsOneWidget);
    expect(find.text(mockChildDashboardData.overviewMetrics.first.value), findsOneWidget);
  });

  testWidgets('child care dashboard switches from stacked to split layout', (
    WidgetTester tester,
  ) async {
    Future<void> pumpAt(Size size) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.highContrast(),
          home: const ChildHomePage(service: _DelayedChildDashboardService()),
        ),
      );
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAt(const Size(390, 844));
    expect(find.byKey(const Key('childDashboardLoading')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('childDashboardStack'), skipOffstage: false),
      300,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('childDashboardStack'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('childDashboardSplit'), skipOffstage: false),
      findsNothing,
    );

    await pumpAt(const Size(900, 900));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('childDashboardSplit'), skipOffstage: false),
      300,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('childDashboardStack'), skipOffstage: false),
      findsNothing,
    );
    expect(
      find.byKey(const Key('childDashboardSplit'), skipOffstage: false),
      findsOneWidget,
    );
  });
}
