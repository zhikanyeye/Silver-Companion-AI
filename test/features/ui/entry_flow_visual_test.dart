import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/features/landing/landing_page.dart';
import 'package:yinling_zhiban_demo/features/role/role_select_page.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

void main() {
  group('entry flow visual polish', () {
    testWidgets('landing page stays stable and adds lightweight motion', (
      WidgetTester tester,
    ) async {
      await _pumpPage(tester, const Size(320, 640), const LandingPage());

      expect(find.byType(AnimatedSlide), findsWidgets);
      expect(find.byType(AnimatedOpacity), findsWidgets);
      expect(tester.takeException(), isNull);

      await _pumpPage(tester, const Size(1280, 900), const LandingPage());

      expect(find.byType(AnimatedSlide), findsWidgets);
      expect(find.byType(AnimatedOpacity), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('auth page stays stable and adds lightweight motion', (
      WidgetTester tester,
    ) async {
      await _pumpPage(tester, const Size(320, 640), const AuthPage());

      expect(find.byType(AnimatedSlide), findsWidgets);
      expect(tester.takeException(), isNull);

      await _pumpPage(tester, const Size(1280, 900), const AuthPage());

      expect(find.byType(AnimatedSlide), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('role page stays stable and adds lightweight motion', (
      WidgetTester tester,
    ) async {
      await _pumpPage(tester, const Size(320, 640), const RoleSelectPage());

      expect(find.byType(AnimatedSlide), findsWidgets);
      expect(tester.takeException(), isNull);

      await _pumpPage(tester, const Size(1280, 900), const RoleSelectPage());

      expect(find.byType(AnimatedSlide), findsWidgets);
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
