import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/features/child/child_home_page.dart';
import 'package:yinling_zhiban_demo/features/elderly/elderly_home_page.dart';
import 'package:yinling_zhiban_demo/features/landing/landing_page.dart';
import 'package:yinling_zhiban_demo/features/role/role_select_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('navigates from landing to auth to role selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    final landingPage = find.byType(LandingPage);

    expect(landingPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(landingPage))?.settings.name,
      landingRoute,
    );

    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pumpAndSettle();

    final authPage = find.byType(AuthPage);

    expect(authPage, findsOneWidget);
    expect(ModalRoute.of(tester.element(authPage))?.settings.name, authRoute);
    expect(find.text('欢迎回来'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '13800138000');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, '进入角色选择'));
    await tester.pumpAndSettle();

    final roleSelectPage = find.byType(RoleSelectPage);

    expect(roleSelectPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(roleSelectPage))?.settings.name,
      roleSelectRoute,
    );
    expect(find.widgetWithText(ElevatedButton, '我是老人'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '我是子女'), findsOneWidget);
    expect(find.text('平台端'), findsNothing);
  });

  testWidgets('keeps elderly and child routes reachable from role selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '13800138000');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, '进入角色选择'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, '我是老人'));
    await tester.pumpAndSettle();

    final elderlyPage = find.byType(ElderlyHomePage);

    expect(elderlyPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(elderlyPage))?.settings.name,
      elderlyRoute,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, '我是子女'));
    await tester.pumpAndSettle();

    final childPage = find.byType(ChildHomePage);

    expect(childPage, findsOneWidget);
    expect(ModalRoute.of(tester.element(childPage))?.settings.name, childRoute);
  });
}
