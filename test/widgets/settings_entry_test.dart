import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/routes.dart';

void main() {
  testWidgets('settings route loads from the app router',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'openrouter_model': 'openai/gpt-4o-mini',
    });
    await tester.pumpWidget(const App(initialRoute: settingsRoute));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settingsServiceShell')), findsOneWidget);
    expect(find.text('Service Settings'), findsOneWidget);
    expect(find.text('Cloud services connected'), findsOneWidget);
    expect(
      find.text('Model selection is loaded from cloud configuration.'),
      findsOneWidget,
    );
    expect(find.text('Current Model'), findsOneWidget);
    expect(find.text('openai/gpt-4o-mini'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
