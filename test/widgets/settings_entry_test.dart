import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling/app.dart';
import 'package:yinling/routes.dart';
import 'package:yinling/services/auth_session_store.dart';

void main() {
  testWidgets('settings route loads from the app router', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AuthSessionStore.isLoggedInPreferenceKey: true,
      'openrouter_model': 'openai/gpt-4o-mini',
    });
    await tester.pumpWidget(const App(initialRoute: settingsRoute));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settingsServiceShell')), findsOneWidget);
    expect(find.text('使用偏好'), findsOneWidget);
    expect(find.text('银聆服务运行正常'), findsOneWidget);
    expect(find.text('陪伴聊天、语音播报和服务转接都可以正常使用。'), findsOneWidget);
    expect(find.text('陪伴助手'), findsOneWidget);
    expect(find.text('已为您选择合适的陪伴服务'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
