import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/child/child_home_page.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

import 'support/app_flow_test_helper.dart';

void main() {
  testWidgets('child route shows care dashboard overview metrics and alerts', (
    WidgetTester tester,
  ) async {
    await pumpAppToChildHome(tester);

    expect(find.text('子女端'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('家庭关怀总览'), findsOneWidget);
    expect(find.text('今天的照护重点已经为您整理好。'), findsOneWidget);
    expect(find.text('今日整体状态'), findsOneWidget);
    expect(find.text('照护指标'), findsOneWidget);
    expect(find.text('今日活跃'), findsOneWidget);
    expect(find.text('情绪趋势'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('20:00 睡前阅读'), 200);
    await tester.pumpAndSettle();

    expect(find.text('今日提醒'), findsOneWidget);
    expect(find.text('按时喝水提醒'), findsOneWidget);
    expect(find.text('20:00 睡前阅读'), findsOneWidget);
  });

  testWidgets('child care dashboard switches from stacked to split layout', (
    WidgetTester tester,
  ) async {
    Future<void> pumpAt(Size size) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.highContrast(), home: const ChildHomePage()),
      );
      await tester.pumpAndSettle();
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAt(const Size(390, 844));
    expect(find.text('家庭关怀总览'), findsOneWidget);
    expect(find.text('照护指标'), findsOneWidget);
    expect(find.text('今日提醒'), findsOneWidget);
    expect(find.byKey(const Key('childDashboardStack')), findsOneWidget);
    expect(find.byKey(const Key('childDashboardSplit')), findsNothing);

    await pumpAt(const Size(900, 900));
    expect(find.text('家庭关怀总览'), findsOneWidget);
    expect(find.text('照护指标'), findsOneWidget);
    expect(find.text('今日提醒'), findsOneWidget);
    expect(find.byKey(const Key('childDashboardStack')), findsNothing);
    expect(find.byKey(const Key('childDashboardSplit')), findsOneWidget);

    await pumpAt(const Size(1280, 900));
    expect(find.text('家庭关怀总览'), findsOneWidget);
    expect(find.text('照护指标'), findsOneWidget);
    expect(find.text('今日提醒'), findsOneWidget);
    expect(find.byKey(const Key('childDashboardStack')), findsNothing);
    expect(find.byKey(const Key('childDashboardSplit')), findsOneWidget);
  });
}
