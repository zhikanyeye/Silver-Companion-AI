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
    expect(find.text('Silver Companion'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.byType(BrandHero), findsOneWidget);
    expect(find.byKey(const Key('landingBrandActionBar')), findsOneWidget);
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
    expect(find.byKey(const Key('landingBrandActionBar')), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);

    await pumpAt(const Size(1280, 900));
    expect(find.byType(BrandHero), findsOneWidget);
    expect(find.byKey(const Key('landingBrandActionBar')), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
  });

  testWidgets('landing login action routes to auth', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
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

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
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
