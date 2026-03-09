import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('opens community feed and shows post cards with publish action',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.tap(find.text('长者'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('社区互助'));
    await tester.pumpAndSettle();

    expect(find.text('社区互助'), findsOneWidget);
    expect(find.byKey(const Key('communityPostCard_0')), findsOneWidget);
    expect(find.text('求助'), findsOneWidget);
    expect(find.text('朝阳区'), findsOneWidget);
    expect(find.text('10分钟前'), findsOneWidget);
    expect(find.text('家里灯泡坏了，谁能帮忙换一下？我在3号楼。'), findsOneWidget);
    expect(find.text('发布互助'), findsOneWidget);
  });
}
