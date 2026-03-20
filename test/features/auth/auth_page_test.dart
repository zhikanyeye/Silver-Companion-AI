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

    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('登录'), findsWidgets);
    expect(find.text('注册'), findsWidgets);
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.text('欢迎使用银龄智伴'), findsOneWidget);
    expect(find.text('使用手机号和密码继续。'), findsOneWidget);
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
    expect(find.text('欢迎使用银龄智伴'), findsOneWidget);
    expect(find.text('填写基础信息后即可开始使用。'), findsOneWidget);
    expect(find.text('欢迎回来'), findsNothing);
    expect(find.text('姓名'), findsOneWidget);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
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
    final compactScrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    final compactBox = tester.widget<ConstrainedBox>(
      find.ancestor(of: find.byType(Card), matching: find.byType(ConstrainedBox)),
    );
    expect(compactScrollView.padding, const EdgeInsets.symmetric(horizontal: 16, vertical: 16));
    expect(compactBox.constraints.maxWidth, 680);
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '进入角色选择'), findsOneWidget);

    await pumpAt(const Size(1280, 900));
    final wideScrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    final wideBox = tester.widget<ConstrainedBox>(
      find.ancestor(of: find.byType(Card), matching: find.byType(ConstrainedBox)),
    );
    expect(wideScrollView.padding, const EdgeInsets.symmetric(horizontal: 32, vertical: 28));
    expect(wideBox.constraints.maxWidth, 680);
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '进入角色选择'), findsOneWidget);
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
