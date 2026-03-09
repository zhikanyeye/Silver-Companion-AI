import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/features/community/community_feed_page.dart';
import 'package:yinling_zhiban_demo/features/community/mock_posts.dart';

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
    expect(find.byKey(const Key('communityPostCard_1')), findsOneWidget);
    expect(find.byType(Card), findsAtLeastNWidgets(2));
    expect(find.text('求助'), findsOneWidget);
    expect(find.text('朝阳区'), findsOneWidget);
    expect(find.text('10分钟前'), findsOneWidget);
    expect(find.text('家里灯泡坏了，谁能帮忙换一下？我在3号楼。'), findsOneWidget);
    expect(find.text('发布互助'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('发布互助（演示）'), findsOneWidget);
  });

  testWidgets('can render feed with injected posts data',
      (WidgetTester tester) async {
    const customPosts = [
      CommunityPost(
        username: '测试用户',
        tag: '互助',
        location: '测试街道',
        time: '刚刚',
        content: '这是注入的数据',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(home: CommunityFeedPage(posts: customPosts)),
    );

    expect(find.text('这是注入的数据'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });
}
