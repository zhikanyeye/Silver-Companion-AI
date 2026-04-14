import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/app.dart';
import 'package:yinling/features/child/child_home_page.dart';
import 'package:yinling/features/elderly/elderly_home_page.dart';
import 'package:yinling/routes.dart';

void main() {
  testWidgets('boots directly to elderly route by legacy route name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App(initialRoute: elderlyRoute));
    await tester.pumpAndSettle();

    final elderlyPage = find.byType(ElderlyHomePage);

    expect(elderlyPage, findsOneWidget);
    expect(ModalRoute.of(tester.element(elderlyPage))?.settings.name, elderlyRoute);
  });

  testWidgets('boots directly to child route by legacy route name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App(initialRoute: childRoute));
    await tester.pumpAndSettle();

    final childPage = find.byType(ChildHomePage);

    expect(childPage, findsOneWidget);
    expect(ModalRoute.of(tester.element(childPage))?.settings.name, childRoute);
  });
}
