import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/widgets/brand_hero.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('landing shows brand-first entry with auth actions only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    final scaffold = find.byType(Scaffold).first;

    expect(ModalRoute.of(tester.element(scaffold))?.settings.name, landingRoute);
    expect(find.text('银龄智伴'), findsWidgets);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('注册'), findsOneWidget);
    expect(find.text('我是老人'), findsNothing);
    expect(find.text('我是子女'), findsNothing);
    expect(find.text('老人端'), findsNothing);
    expect(find.text('子女端'), findsNothing);
    expect(find.byType(BrandHero), findsOneWidget);
    expect(find.text('更简单地开始陪伴'), findsNothing);
    expect(find.text('安心开始'), findsNothing);
    expect(find.text('一步完成'), findsNothing);
    expect(find.text('品牌优先'), findsNothing);
    expect(find.text('入口统一'), findsNothing);
  });

  testWidgets('landing keeps a single hero and auth actions on small and wide screens', (
    WidgetTester tester,
  ) async {
    Future<void> pumpAt(Size size) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAt(const Size(375, 812));
    expect(find.byType(BrandHero), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '登录'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '注册'), findsOneWidget);
    expect(find.text('更简单地开始陪伴'), findsNothing);

    await pumpAt(const Size(1280, 900));
    expect(find.byType(BrandHero), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '登录'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '注册'), findsOneWidget);
    expect(find.text('更简单地开始陪伴'), findsNothing);
  });

  testWidgets('landing login action routes to auth', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.text('创建账号'), findsNothing);
    expect(
      ModalRoute.of(tester.element(find.byType(AuthPage)))?.settings.name,
      authRoute,
    );
  });

  testWidgets('landing register action routes to auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, '注册'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('创建账号'), findsOneWidget);
    expect(find.text('欢迎回来'), findsNothing);
    expect(
      ModalRoute.of(tester.element(find.byType(AuthPage)))?.settings.name,
      authRoute,
    );
  });
}
