import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/features/role/role_select_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

void main() {
  testWidgets('landing login opens auth page on login tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(OutlinedButton, '观看演示'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Register'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Welcome to Silver Companion'), findsOneWidget);
    expect(find.text('Continue with your phone number and password.'), findsOneWidget);
    expect(find.text('Create account'), findsNothing);
    expect(find.text('Name'), findsNothing);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('landing register opens auth page on register tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, '立即开始'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Welcome to Silver Companion'), findsOneWidget);
    expect(find.text('Fill in the basics to get started.'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('auth page adapts spacing for small and wide screens', (
    WidgetTester tester,
  ) async {
    Future<void> pumpAt(Size size) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.highContrast(),
          home: const AuthPage(),
        ),
      );
      await tester.pumpAndSettle();
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAt(const Size(375, 812));
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Enter role selection'), findsOneWidget);

    await pumpAt(const Size(1280, 900));
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Enter role selection'), findsOneWidget);
  });

  testWidgets('auth login form navigates to role selection after valid submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(OutlinedButton, '观看演示'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '13800138000');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enter role selection'));
    await tester.pumpAndSettle();

    expect(find.byType(RoleSelectPage), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(RoleSelectPage)))?.settings.name,
      roleSelectRoute,
    );
  });
}
