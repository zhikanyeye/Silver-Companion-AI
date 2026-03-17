import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

Future<void> pumpAppToRoleSelect(WidgetTester tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.widgetWithText(TextFormField, '手机号'),
    '13800000000',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, '密码'),
    'password123',
  );

  await tester.tap(find.widgetWithText(ElevatedButton, '进入角色选择'));
  await tester.pumpAndSettle();

  expect(find.text('请选择您的身份'), findsOneWidget);
}

Future<void> pumpAppToElderlyHome(WidgetTester tester) async {
  await pumpAppToRoleSelect(tester);

  await tester.tap(find.widgetWithText(ElevatedButton, '我是老人'));
  await tester.pumpAndSettle();
}

Future<void> pumpAppToChildHome(WidgetTester tester) async {
  await pumpAppToRoleSelect(tester);

  await tester.tap(find.widgetWithText(ElevatedButton, '我是子女'));
  await tester.pumpAndSettle();
}
