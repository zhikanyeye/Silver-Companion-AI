import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('elderly route shows required entries and avatar opens chat',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.text('长者'));
    await tester.pumpAndSettle();

    expect(find.text('长者服务'), findsOneWidget);
    expect(find.text('AI陪伴'), findsOneWidget);
    expect(find.text('一键求助'), findsOneWidget);
    expect(find.text('社区互助'), findsOneWidget);
    expect(find.text('活动'), findsOneWidget);
    expect(find.byKey(const Key('childAvatarEntry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('childAvatarEntry')));
    await tester.pumpAndSettle();

    expect(find.text('AI陪伴聊天'), findsOneWidget);
    expect(find.byKey(const Key('chatInputField')), findsOneWidget);
    expect(find.byKey(const Key('sendMessageButton')), findsOneWidget);
  });
}
