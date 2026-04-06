import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

Future<void> pumpAppToRoleSelect(WidgetTester tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(OutlinedButton, '观看演示'));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '13800000000');
  await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

  await tester.tap(find.widgetWithText(ElevatedButton, 'Enter role selection'));
  await tester.pumpAndSettle();

  expect(find.text('Select your role'), findsOneWidget);
}

Future<void> pumpAppToElderlyHome(WidgetTester tester) async {
  await pumpAppToRoleSelect(tester);
  await tester.tap(find.widgetWithText(ElevatedButton, 'I am an elder'));
  await tester.pumpAndSettle();
}

Future<void> pumpAppToChildHome(WidgetTester tester) async {
  await pumpAppToRoleSelect(tester);
  await tester.tap(find.widgetWithText(ElevatedButton, 'I am a child'));
  await tester.pumpAndSettle();
}
