import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_flow_test_helper.dart';

void main() {
  testWidgets('elderly route shows required entries and avatar opens chat',
      (WidgetTester tester) async {
    await pumpAppToElderlyHome(tester);

    expect(find.text('老人端'), findsOneWidget);
    expect(find.text('今天也有人陪你慢慢聊'), findsOneWidget);
    expect(find.text('AI陪伴'), findsOneWidget);
    expect(find.text('一键求助'), findsOneWidget);
    expect(find.text('社区互助'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('活动'), 200);
    await tester.pumpAndSettle();

    expect(find.text('活动'), findsOneWidget);
    expect(find.byKey(const Key('childAvatarEntry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('childAvatarEntry')));
    await tester.pumpAndSettle();

    expect(find.text('AI智能助手'), findsOneWidget);
    expect(find.byKey(const Key('chatInputField')), findsOneWidget);
    expect(find.byKey(const Key('sendMessageButton')), findsOneWidget);
  });

  testWidgets('elderly AI companion action shows coming soon feedback',
      (WidgetTester tester) async {
    await pumpAppToElderlyHome(tester);

    await tester.tap(find.text('AI陪伴'));
    await tester.pump();

    expect(find.text('功能即将开放'), findsOneWidget);
  });
}
