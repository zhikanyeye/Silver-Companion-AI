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

    expect(find.text('Select your role'), findsOneWidget);
    expect(find.text('We will take you to the role-specific experience.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'I am an elder'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'I am a child'), findsOneWidget);
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

    final elderlyButton = find.widgetWithText(ElevatedButton, 'I am an elder');
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

    final childButton = find.widgetWithText(ElevatedButton, 'I am a child');
    await tester.tap(childButton);
    await tester.pumpAndSettle();

    expect(find.text('child target'), findsOneWidget);
  });
}
