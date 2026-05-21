import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/app.dart';
import 'package:yinling/features/auth/auth_page.dart';
import 'package:yinling/features/role/role_select_page.dart';
import 'package:yinling/features/landing/landing_page.dart';
import 'package:yinling/routes.dart';

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
    expect(find.text('立即开始'), findsOneWidget);
    expect(find.text('观看演示'), findsOneWidget);
    expect(find.byType(AuthPage), findsNothing);
    expect(find.byType(RoleSelectPage), findsNothing);
    expect(find.byType(SelectionArea), findsOneWidget);
  });
}
