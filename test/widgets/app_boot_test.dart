import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/auth/auth_page.dart';
import 'package:yinling_zhiban_demo/features/role/role_select_page.dart';
import 'package:yinling_zhiban_demo/features/landing/landing_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('shows landing page before auth and role selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    final landingPage = find.byType(LandingPage);

    expect(landingPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(landingPage))?.settings.name,
      landingRoute,
    );
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.byType(AuthPage), findsNothing);
    expect(find.byType(RoleSelectPage), findsNothing);
  });
}
