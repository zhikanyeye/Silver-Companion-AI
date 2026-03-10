import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('home shows settings entry and navigates to settings page',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const App());

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('老人端'), findsOneWidget);
    expect(find.text('子女端'), findsOneWidget);
    expect(find.text('平台端'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '设置'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });
}
