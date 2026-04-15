import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling/features/auth/auth_page.dart';
import 'package:yinling/features/auth/widgets/auth_tabs.dart';
import 'package:yinling/features/role/role_select_page.dart';
import 'package:yinling/routes.dart';
import 'package:yinling/services/auth_session_store.dart';
import 'package:yinling/theme/app_theme.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('login tab shows two fields and the test-stage notice', (
    WidgetTester tester,
  ) async {
    await pumpAuthPage(tester);

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('登录测试提醒'), findsOneWidget);
    expect(find.textContaining('账号和密码可随意填写'), findsOneWidget);
  });

  testWidgets('register tab shows three fields and the test-stage notice', (
    WidgetTester tester,
  ) async {
    await pumpAuthPage(tester, initialTab: AuthTabSelection.register);

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('注册测试提醒'), findsOneWidget);
    expect(find.textContaining('注册信息可随意填写'), findsOneWidget);
  });

  testWidgets('auth page adapts to small and wide screens', (
    WidgetTester tester,
  ) async {
    await pumpAuthPage(tester, size: const Size(375, 812));
    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(AuthTabs), findsOneWidget);

    await pumpAuthPage(tester, size: const Size(1280, 900));
    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(AuthTabs), findsOneWidget);
  });

  testWidgets(
    'auth login form navigates to role selection after valid submit',
    (WidgetTester tester) async {
      await pumpAuthPage(tester);

      await tester.enterText(find.byType(TextFormField).at(0), '13800138000');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(RoleSelectPage), findsOneWidget);
      expect(
        ModalRoute.of(
          tester.element(find.byType(RoleSelectPage)),
        )?.settings.name,
        roleSelectRoute,
      );

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getBool(AuthSessionStore.isLoggedInPreferenceKey),
        isTrue,
      );
    },
  );

  testWidgets('test-stage notice auto dismisses after five seconds', (
    WidgetTester tester,
  ) async {
    await pumpAuthPage(tester);

    expect(find.text('登录测试提醒'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('登录测试提醒'), findsNothing);
  });

  testWidgets('test-stage notice only appears once for each auth tab', (
    WidgetTester tester,
  ) async {
    await pumpAuthPage(tester);

    expect(find.text('登录测试提醒'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await pumpAuthPage(tester);
    expect(find.text('登录测试提醒'), findsNothing);

    final registerTabButton = find
        .descendant(
          of: find.byType(AuthTabs),
          matching: find.byType(TextButton),
        )
        .at(1);

    await tester.tap(registerTabButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('注册测试提醒'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await pumpAuthPage(tester, initialTab: AuthTabSelection.register);
    expect(find.text('注册测试提醒'), findsNothing);
  });
}

Future<void> pumpAuthPage(
  WidgetTester tester, {
  AuthTabSelection initialTab = AuthTabSelection.login,
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.highContrast(),
      onGenerateInitialRoutes: (initialRoute) => <Route<dynamic>>[
        MaterialPageRoute<void>(
          settings: RouteSettings(name: authRoute, arguments: initialTab),
          builder: (_) => const AuthPage(),
        ),
      ],
      onGenerateRoute: (settings) {
        if (settings.name == roleSelectRoute) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const RoleSelectPage(),
          );
        }
        return null;
      },
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
