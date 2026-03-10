import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('respects system text scaling above app minimum',
      (WidgetTester tester) async {
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(() {
      tester.binding.platformDispatcher.textScaleFactorTestValue = 1.0;
    });

    await tester.pumpWidget(const App());

    final context = tester.element(find.byType(HomeSelectorScreen));
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    expect(scale, greaterThanOrEqualTo(1.4));
  });

  testWidgets('navigates to elderly route from home selector',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.text('老人端'));
    await tester.pumpAndSettle();

    expect(find.text('老人端'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('navigates to child route from home selector',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.text('子女端'));
    await tester.pumpAndSettle();

    expect(find.text('子女端'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('navigates to platform route from home selector',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    final platformCard = find.widgetWithText(Card, '平台端');

    expect(platformCard, findsOneWidget);

    await tester.ensureVisible(platformCard);
    await tester.pumpAndSettle();
    await tester.tap(platformCard);
    await tester.pumpAndSettle();

    final platformPage = find.byType(PlatformPlaceholderPage);

    expect(platformPage, findsOneWidget);

    final route = ModalRoute.of(tester.element(platformPage));

    expect(route?.settings.name, platformRoute);
    expect(find.text('平台端演示功能即将开放'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
