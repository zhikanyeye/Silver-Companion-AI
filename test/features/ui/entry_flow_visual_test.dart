import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/features/landing/landing_page.dart';
import 'package:yinling_zhiban_demo/features/role/role_select_page.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';
import 'package:yinling_zhiban_demo/widgets/brand_hero.dart';

void main() {
  group('entry flow visual polish', () {
    testWidgets('landing page stays stable and renders brand hero', (
      WidgetTester tester,
    ) async {
      await _pumpPage(tester, const Size(320, 640), const LandingPage());
      expect(find.byType(BrandHero), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pumpPage(tester, const Size(1280, 900), const LandingPage());
      expect(find.byType(BrandHero), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('auth page stays stable across sizes', (
      WidgetTester tester,
    ) async {
      await _pumpPage(tester, const Size(320, 640), const AuthPage());
      expect(find.text('Welcome back'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pumpPage(tester, const Size(1280, 900), const AuthPage());
      expect(find.text('Welcome back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('role page stays stable across sizes', (
      WidgetTester tester,
    ) async {
      await _pumpPage(tester, const Size(320, 640), const RoleSelectPage());
      expect(find.text('Select your role'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pumpPage(tester, const Size(1280, 900), const RoleSelectPage());
      expect(find.text('Select your role'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpPage(WidgetTester tester, Size size, Widget page) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.highContrast(),
      home: page,
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}
