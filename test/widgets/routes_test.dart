import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('navigates to elderly route from home selector',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.text('长者'));
    await tester.pumpAndSettle();

    expect(find.text('长者服务'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('navigates to child route from home selector',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.text('儿童'));
    await tester.pumpAndSettle();

    expect(find.text('儿童服务'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
