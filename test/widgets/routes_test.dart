import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

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
}
