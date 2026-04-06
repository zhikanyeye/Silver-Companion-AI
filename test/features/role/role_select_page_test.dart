import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/role/role_select_page.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('shows cleaner role selection copy with exactly two options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RoleSelectPage()),
    );

    expect(find.text('请选择您的身份'), findsOneWidget);
    expect(find.text('我们将带您进入对应身份的服务页面。'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '我是长者'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '我是子女'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
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

    final elderlyButton = find.widgetWithText(ElevatedButton, '我是长者');
    await tester.tap(elderlyButton);
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

    final childButton = find.widgetWithText(ElevatedButton, '我是子女');
    await tester.tap(childButton);
    await tester.pumpAndSettle();

    expect(find.text('child target'), findsOneWidget);
  });
}
