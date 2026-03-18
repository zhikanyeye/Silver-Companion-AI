import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/community/community_feed_page.dart';
import 'package:yinling_zhiban_demo/features/community/mock_posts.dart';

import 'support/app_flow_test_helper.dart';

void main() {
  testWidgets('opens community feed and shows post cards with publish action',
      (WidgetTester tester) async {
    await pumpAppToElderlyHome(tester);

    await tester.tap(find.text('社区互助'));
    await tester.pumpAndSettle();

    expect(find.text('社区互助'), findsOneWidget);
    expect(find.text('看看邻里间正在发生的帮助与回应'), findsOneWidget);
    expect(find.text('社区公告'), findsOneWidget);
    expect(find.text('防诈提醒'), findsOneWidget);
    expect(find.text('本周活动'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('推荐'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('推荐'), findsOneWidget);
    expect(find.text('最新'), findsOneWidget);
    expect(find.byKey(const Key('communityPostCard_0')), findsOneWidget);
    expect(find.byKey(const Key('communityPostCard_1')), findsNothing);
    expect(find.byType(Card), findsAtLeastNWidgets(2));
    expect(find.text('代取药顺路互助'), findsNothing);
    expect(find.text('求助'), findsOneWidget);
    expect(find.text('朝阳区'), findsOneWidget);
    expect(find.text('10分钟前'), findsOneWidget);
    expect(find.text('3号楼灯泡更换求助'), findsOneWidget);
    expect(find.text('家里灯泡坏了，希望有邻居方便时帮忙看一下。'), findsOneWidget);
    expect(find.text('等待帮助中'), findsOneWidget);
    expect(find.text('王阿姨'), findsOneWidget);
    expect(find.text('3号楼住户'), findsOneWidget);
    expect(find.text('发布互助'), findsOneWidget);

    await tester.tap(find.text('最新'));
    await tester.pumpAndSettle();

    expect(find.text('3号楼灯泡更换求助'), findsNothing);
    expect(find.text('代取药顺路互助'), findsOneWidget);
    expect(find.text('已有2人响应'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('已收到发布请求'), findsOneWidget);
  });

  testWidgets('can render feed with injected posts data',
      (WidgetTester tester) async {
    const customPosts = [
      CommunityPost(
        username: '测试用户',
        identity: '测试社区志愿者',
        tag: '互助',
        title: '测试标题',
        location: '测试街道',
        time: '刚刚',
        summary: '这是注入的数据',
        responseStatus: '已有1人响应',
        bucket: CommunityFeedBucket.recommended,
      ),
      CommunityPost(
        username: '最新用户',
        identity: '最新分栏住户',
        tag: '求助',
        title: '最新分栏标题',
        location: '最新街道',
        time: '1分钟前',
        summary: '这是最新分栏的数据',
        responseStatus: '等待帮助中',
        bucket: CommunityFeedBucket.latest,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(home: CommunityFeedPage(posts: customPosts)),
    );

    expect(find.text('看看邻里间正在发生的帮助与回应'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('测试标题'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('测试标题'), findsOneWidget);
    expect(find.text('这是注入的数据'), findsOneWidget);
    expect(find.text('测试社区志愿者'), findsOneWidget);
    expect(find.text('已有1人响应'), findsOneWidget);
    expect(find.text('最新分栏标题'), findsNothing);
    expect(find.byKey(const Key('communityPostCard_0')), findsOneWidget);
    expect(find.byType(Card), findsAtLeastNWidgets(1));

    await tester.tap(find.text('最新'));
    await tester.pumpAndSettle();

    expect(find.text('测试标题'), findsNothing);
    expect(find.text('最新分栏标题'), findsOneWidget);
    expect(find.text('这是最新分栏的数据'), findsOneWidget);
  });
}
