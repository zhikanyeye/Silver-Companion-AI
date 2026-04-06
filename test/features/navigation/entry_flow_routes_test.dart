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

    await tester.tap(find.widgetWithText(OutlinedButton, '观看演示'));
    await tester.pumpAndSettle();

    final authPage = find.byType(AuthPage);

    expect(authPage, findsOneWidget);
    expect(ModalRoute.of(tester.element(authPage))?.settings.name, authRoute);
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '13800138000');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enter role selection'));
    await tester.pumpAndSettle();

    final roleSelectPage = find.byType(RoleSelectPage);

    expect(roleSelectPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(roleSelectPage))?.settings.name,
      roleSelectRoute,
    );
    expect(find.widgetWithText(ElevatedButton, 'I am an elder'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'I am a child'), findsOneWidget);
    expect(find.text('Platform'), findsNothing);
  });

  testWidgets('keeps elderly and child routes reachable from role selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(OutlinedButton, '观看演示'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '13800138000');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enter role selection'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'I am an elder'));
    await tester.pumpAndSettle();

    final elderlyPage = find.byType(ElderlyHomePage);

    expect(elderlyPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(elderlyPage))?.settings.name,
      elderlyRoute,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'I am a child'));
    await tester.pumpAndSettle();

    final childPage = find.byType(ChildHomePage);

    expect(childPage, findsOneWidget);
    expect(ModalRoute.of(tester.element(childPage))?.settings.name, childRoute);
  });
}
