import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/features/role/role_select_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('landing login opens auth page on login tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('登录'), findsWidgets);
    expect(find.text('注册'), findsWidgets);
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.text('创建账号'), findsNothing);
    expect(find.text('姓名'), findsNothing);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
  });

  testWidgets('landing register opens auth page on register tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, '注册'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('创建账号'), findsOneWidget);
    expect(find.text('欢迎回来'), findsNothing);
    expect(find.text('姓名'), findsOneWidget);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
  });

  testWidgets('auth login form navigates to role selection after valid submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '13800138000');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, '进入角色选择'));
    await tester.pumpAndSettle();

    expect(find.byType(RoleSelectPage), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(RoleSelectPage)))?.settings.name,
      roleSelectRoute,
    );
  });
}
