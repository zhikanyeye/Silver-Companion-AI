import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/landing/landing_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';

import 'support/app_flow_test_helper.dart';

void main() {
  testWidgets('respects system text scaling above app minimum',
      (WidgetTester tester) async {
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(() {
      tester.binding.platformDispatcher.textScaleFactorTestValue = 1.0;
    });

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(LandingPage));
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    expect(scale, greaterThanOrEqualTo(1.4));
  });

  testWidgets('navigates to elderly route from landing auth and role flow',
      (WidgetTester tester) async {
    await pumpAppToElderlyHome(tester);

    expect(find.text('老人端'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('navigates to child route from landing auth and role flow',
      (WidgetTester tester) async {
    await pumpAppToChildHome(tester);

    expect(find.text('子女端'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('navigates to platform route when launched on platform route',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App(initialRoute: platformRoute));
    await tester.pumpAndSettle();

    final platformText = find.text('平台端');
    expect(platformText, findsOneWidget);

    final platformPage = find.byType(PlatformPlaceholderPage);

    expect(platformPage, findsOneWidget);

    final route = ModalRoute.of(tester.element(platformPage));

    expect(route?.settings.name, platformRoute);
    expect(find.text('平台端演示功能即将开放'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
