import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/elderly/elderly_activities_page.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

void main() {
  testWidgets('activities page shows grouped sections and opens activity details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: const ElderlyActivitiesPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('活动安排'), findsWidgets);
    expect(find.text('今日推荐'), findsOneWidget);
    expect(find.text('把今天和本周适合参与的社区活动整理在一起，方便按时间查看。'), findsOneWidget);
    expect(find.text('晨间舒缓操'), findsOneWidget);

    await tester.tap(find.text('晨间舒缓操'));
    await tester.pumpAndSettle();

    expect(find.text('活动详情'), findsOneWidget);
    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('社区活动室 A 区')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('由社区志愿者带领进行轻强度活动，适合晨间舒展。'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('我知道了'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('本周活动'), 200);
    await tester.pumpAndSettle();
    expect(find.text('本周活动'), findsOneWidget);
  });
}
