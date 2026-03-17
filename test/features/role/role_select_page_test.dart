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
    expect(find.text('我们会带您进入对应的专属入口。'), findsOneWidget);
    expect(find.text('Task 1 保持最小可导航骨架，后续再补充视觉细节。'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, '我是老人'), findsOneWidget);
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

    final elderlyButton = find.widgetWithText(ElevatedButton, '我是老人');

    await tester.scrollUntilVisible(
      elderlyButton,
      100,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    await tester.tap(elderlyButton.hitTestable());
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

    await tester.scrollUntilVisible(
      childButton,
      100,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    await tester.tap(childButton.hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('child target'), findsOneWidget);
  });
}
