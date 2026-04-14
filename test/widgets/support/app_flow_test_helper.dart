import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/app.dart';

Future<void> pumpAppToRoleSelect(WidgetTester tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(OutlinedButton, '观看演示'));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.widgetWithText(TextFormField, '手机号'),
    '13800000000',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, '密码'),
    'password123',
  );

  await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
  await tester.pumpAndSettle();

  expect(find.text('选择您的身份'), findsOneWidget);
}

Future<void> pumpAppToElderlyHome(WidgetTester tester) async {
  await pumpAppToRoleSelect(tester);
  await tester.tap(find.text('我是长辈').first);
  await tester.pumpAndSettle();
}

Future<void> pumpAppToChildHome(WidgetTester tester) async {
  await pumpAppToRoleSelect(tester);
  await tester.tap(find.text('我是子女').first);
  await tester.pumpAndSettle();
}
