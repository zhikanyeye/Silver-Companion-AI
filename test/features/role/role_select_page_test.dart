import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/features/role/role_select_page.dart';
import 'package:yinling/routes.dart';

void main() {
  testWidgets('shows cleaner role selection copy with exactly two options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RoleSelectPage()),
    );

    expect(find.text('选择您的身份'), findsOneWidget);
    expect(find.text('我是长辈'), findsOneWidget);
    expect(find.text('我是子女'), findsOneWidget);
    expect(find.byType(RoleSelectPage), findsOneWidget);
  });

  testWidgets('routes elderly option to its existing destination', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: roleSelectRoute,
        routes: {
          roleSelectRoute: (context) => const RoleSelectPage(),
          elderlyRoute: (context) => const Scaffold(body: Text('elderly target')),
        },
      ),
    );

    final elderlyCard = find.text('我是长辈');
    await tester.tap(elderlyCard);
    await tester.pumpAndSettle();

    expect(find.text('elderly target'), findsOneWidget);
  });

  testWidgets('routes child option to its existing destination', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: roleSelectRoute,
        routes: {
          roleSelectRoute: (context) => const RoleSelectPage(),
          childRoute: (context) => const Scaffold(body: Text('child target')),
        },
      ),
    );

    final childCard = find.text('我是子女');
    await tester.tap(childCard);
    await tester.pumpAndSettle();

    expect(find.text('child target'), findsOneWidget);
  });
}
