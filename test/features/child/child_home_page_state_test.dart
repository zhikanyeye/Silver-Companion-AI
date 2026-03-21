import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:yinling_zhiban_demo/features/child/child_dashboard_service.dart';
import 'package:yinling_zhiban_demo/features/child/child_home_page.dart';
import 'package:yinling_zhiban_demo/features/child/mock_family_data.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class _FailingChildDashboardService extends ChildDashboardService {
  const _FailingChildDashboardService();

  @override
  Future<ChildDashboardData> loadDashboard() async {
    throw Exception('load failed');
  }
}

class _CountingChildDashboardService extends ChildDashboardService {
  _CountingChildDashboardService();

  int calls = 0;

  @override
  Future<ChildDashboardData> loadDashboard() async {
    calls += 1;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return mockChildDashboardData;
  }
}

class _QueuedChildDashboardService extends ChildDashboardService {
  _QueuedChildDashboardService(this._responses);

  final List<Future<ChildDashboardData> Function()> _responses;
  int calls = 0;

  @override
  Future<ChildDashboardData> loadDashboard() {
    final index = calls;
    calls += 1;
    return _responses[index]();
  }
}

void main() {
  testWidgets('child dashboard shows retry state when service fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: const ChildHomePage(service: _FailingChildDashboardService()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂时无法加载家人近况'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '重新加载'), findsOneWidget);
  });

  testWidgets('child dashboard refreshes through RefreshIndicator', (
    WidgetTester tester,
  ) async {
    final service = _CountingChildDashboardService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: ChildHomePage(service: service),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(service.calls, 1);
    expect(find.text('家庭关怀总览'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(service.calls, greaterThanOrEqualTo(2));
    expect(find.text('家庭关怀总览'), findsOneWidget);
  });

  testWidgets('child dashboard keeps existing content visible while refresh is in flight', (
    WidgetTester tester,
  ) async {
    final refreshCompleter = Completer<ChildDashboardData>();
    final service = _QueuedChildDashboardService([
      () async => mockChildDashboardData,
      () => refreshCompleter.future,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: ChildHomePage(service: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('家庭关怀总览'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();

    expect(find.text('家庭关怀总览'), findsOneWidget);
    expect(find.text('正在整理家人近况...'), findsNothing);

    refreshCompleter.complete(mockChildDashboardData);
    await tester.pumpAndSettle();
  });

  testWidgets('child dashboard keeps last successful content when refresh fails', (
    WidgetTester tester,
  ) async {
    final service = _QueuedChildDashboardService([
      () async => mockChildDashboardData,
      () async => throw Exception('refresh failed'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: ChildHomePage(service: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('家庭关怀总览'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('家庭关怀总览'), findsOneWidget);
    expect(find.text('暂时无法加载家人近况'), findsNothing);
  });
}
