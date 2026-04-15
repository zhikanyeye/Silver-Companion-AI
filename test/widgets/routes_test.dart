import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling/app.dart';
import 'package:yinling/features/child/child_home_page.dart';
import 'package:yinling/features/elderly/elderly_activities_page.dart';
import 'package:yinling/features/elderly/elderly_home_page.dart';
import 'package:yinling/features/landing/landing_page.dart';
import 'package:yinling/routes.dart';
import 'package:yinling/services/auth_session_store.dart';

import 'support/app_flow_test_helper.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('respects system text scaling above app minimum',
      (WidgetTester tester) async {
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(() {
      tester.binding.platformDispatcher.textScaleFactorTestValue = 1.0;
    });

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(LandingPage));
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    expect(scale, greaterThanOrEqualTo(1.4));
  });

  testWidgets('navigates to elderly route from landing auth and role flow',
      (WidgetTester tester) async {
    await pumpAppToElderlyHome(tester);

    expect(find.byType(ElderlyHomePage), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('navigates to child route from landing auth and role flow',
      (WidgetTester tester) async {
    await pumpAppToChildHome(tester);

    expect(find.byType(ChildHomePage), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('navigates to elderly activities from the elderly service hall',
      (WidgetTester tester) async {
    await pumpAppToElderlyHome(tester);

    final activitiesEntry = find.byKey(const Key('elderlyActivitiesEntry'));
    await tester.ensureVisible(activitiesEntry);
    await tester.pumpAndSettle();
    await tester.tap(activitiesEntry.hitTestable());
    await tester.pumpAndSettle();

    expect(find.byType(ElderlyActivitiesPage), findsOneWidget);
    expect(find.byKey(const Key('activitiesMySummaryCard')), findsOneWidget);
  });

  testWidgets('navigates to platform route when launched on platform route',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AuthSessionStore.isLoggedInPreferenceKey: true,
    });
    await tester.pumpWidget(const App(initialRoute: platformRoute));
    await tester.pumpAndSettle();

    final platformText = find.text('平台服务');
    expect(platformText, findsOneWidget);

    final platformPage = find.byType(PlatformPlaceholderPage);

    expect(platformPage, findsOneWidget);

    final route = ModalRoute.of(tester.element(platformPage));

    expect(route?.settings.name, platformRoute);
    expect(find.text('平台服务正在准备中。'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('redirects protected routes back to landing when not logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App(initialRoute: childRoute));
    await tester.pumpAndSettle();

    final landingPage = find.byType(LandingPage);
    expect(landingPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(landingPage))?.settings.name,
      landingRoute,
    );
  });
}
