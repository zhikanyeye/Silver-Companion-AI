import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('child route shows dashboard status cards and alerts',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.text('子女端'));
    await tester.pumpAndSettle();

    expect(find.text('子女端'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('家人近况一眼安心'), findsOneWidget);

    expect(find.text('今日活跃'), findsOneWidget);
    expect(find.text('情绪趋势'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('20:00 睡前阅读'), 200);
    await tester.pumpAndSettle();

    expect(find.text('提醒时间线'), findsOneWidget);
    expect(find.text('按时喝水提醒'), findsOneWidget);
    expect(find.text('20:00 睡前阅读'), findsOneWidget);
  });
}
