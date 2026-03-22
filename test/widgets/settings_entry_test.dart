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
    expect(find.text('服务设置'), findsOneWidget);
    expect(find.text('云端服务已连接'), findsOneWidget);
    expect(find.text('由云端配置管理'), findsOneWidget);
    expect(find.text('当前模型'), findsOneWidget);
    expect(find.text('openai/gpt-4o-mini'), findsOneWidget);
    expect(find.text('访问凭证'), findsNothing);
    expect(find.text('保存设置'), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });
}
