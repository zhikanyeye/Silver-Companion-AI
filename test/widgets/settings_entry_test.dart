import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling/app.dart';
import 'package:yinling/routes.dart';

void main() {
  testWidgets('settings route loads from the app router',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'openrouter_model': 'openai/gpt-4o-mini',
    });
    await tester.pumpWidget(const App(initialRoute: settingsRoute));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settingsServiceShell')), findsOneWidget);
    expect(find.text('服务设置'), findsOneWidget);
    expect(find.text('云端服务已连接'), findsOneWidget);
    expect(
      find.text('模型配置已从云端加载。'),
      findsOneWidget,
    );
    expect(find.text('当前模型'), findsOneWidget);
    expect(find.text('openai/gpt-4o-mini'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
