import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('settings route loads from the app router',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const App(initialRoute: settingsRoute));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'API key'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Model'), findsOneWidget);
  });
}
