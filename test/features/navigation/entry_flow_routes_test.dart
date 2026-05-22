import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/features/child/child_home_page.dart';
import 'package:yinling/features/elderly/elderly_home_page.dart';
import 'package:yinling/features/role/role_select_page.dart';
import 'package:yinling/routes.dart';

import '../../widgets/support/app_flow_test_helper.dart';

void main() {
  testWidgets('navigates from landing to auth to role selection', (
    WidgetTester tester,
  ) async {
    await pumpAppToRoleSelect(tester);

    final roleSelectPage = find.byType(RoleSelectPage);

    expect(roleSelectPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(roleSelectPage))?.settings.name,
      roleSelectRoute,
    );
    expect(find.text('我是长辈'), findsOneWidget);
    expect(find.text('我是子女'), findsOneWidget);
    expect(find.text('我是运营人员'), findsOneWidget);
  });

  testWidgets('keeps elderly and child routes reachable from role selection', (
    WidgetTester tester,
  ) async {
    await pumpAppToRoleSelect(tester);

    await tester.tap(find.text('我是长辈'));
    await tester.pumpAndSettle();

    final elderlyPage = find.byType(ElderlyHomePage);

    expect(elderlyPage, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(elderlyPage))?.settings.name,
      elderlyRoute,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('我是子女'));
    await tester.pumpAndSettle();

    final childPage = find.byType(ChildHomePage);

    expect(childPage, findsOneWidget);
    expect(ModalRoute.of(tester.element(childPage))?.settings.name, childRoute);
  });
}
