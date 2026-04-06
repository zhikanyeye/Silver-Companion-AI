import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('landing shows brand-first entry with auth actions only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    final scaffold = find.byType(Scaffold).first;

    expect(ModalRoute.of(tester.element(scaffold))?.settings.name, landingRoute);
    expect(find.text('银龄智伴'), findsOneWidget);
    expect(find.text('立即开始'), findsOneWidget);
    expect(find.text('观看演示'), findsOneWidget);
    expect(find.text('用户心声'), findsOneWidget);
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
    expect(find.text('银龄智伴'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '立即开始'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '观看演示'), findsOneWidget);

    await pumpAt(const Size(1280, 900));
    expect(find.text('银龄智伴'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '立即开始'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '观看演示'), findsOneWidget);
  });

  testWidgets('landing login action routes to auth', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(OutlinedButton, '观看演示'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Create account'), findsNothing);
    expect(
      ModalRoute.of(tester.element(find.byType(AuthPage)))?.settings.name,
      authRoute,
    );
  });

  testWidgets('landing register action routes to auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, '立即开始'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    expect(
      ModalRoute.of(tester.element(find.byType(AuthPage)))?.settings.name,
      authRoute,
    );
  });
}
