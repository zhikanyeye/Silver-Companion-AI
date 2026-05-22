import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/features/elderly/elderly_home_page.dart';
import 'package:yinling/theme/app_theme.dart';

import 'support/app_flow_test_helper.dart';

void main() {
  testWidgets('elderly route shows service hub and avatar opens chat', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    expect(find.text('长辈首页'), findsOneWidget);
    expect(find.text('第三方服务聚合广场'), findsOneWidget);
    expect(find.text('今日推荐入口'), findsOneWidget);
    expect(find.text('今天想找哪类服务？'), findsOneWidget);
    expect(find.text('常用服务'), findsOneWidget);
    expect(find.text('小灵 AI 陪伴'), findsOneWidget);
    expect(find.text('求助'), findsOneWidget);
    expect(find.text('社区'), findsOneWidget);
    expect(find.text('活动'), findsOneWidget);
    expect(find.text('小灵在线'), findsNothing);
    expect(find.text('家政服务'), findsOneWidget);
    expect(find.text('医疗陪护'), findsOneWidget);
    expect(find.text('12 家接入'), findsOneWidget);
    expect(find.text('查看服务商'), findsWidgets);

    final aiEntry = find.byKey(const Key('elderlyAiCompanionEntry'));
    await tester.ensureVisible(aiEntry);
    await tester.pumpAndSettle();
    await tester.tap(aiEntry.hitTestable());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chatInputField')), findsOneWidget);
    expect(find.byKey(const Key('sendMessageButton')), findsOneWidget);
  });

  testWidgets('elderly community entry still routes to community feed', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    final communityEntry = find.byKey(const Key('elderlyCommunityEntry'));
    await tester.ensureVisible(communityEntry);
    await tester.pumpAndSettle();
    await tester.tap(communityEntry.hitTestable());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('communityServiceShell')), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets(
    'elderly home keeps primary service entries on small and wide screens',
    (WidgetTester tester) async {
      Future<void> pumpAt(Size size) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = size;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.highContrast(),
            home: const ElderlyHomePage(),
          ),
        );
        await tester.pumpAndSettle();
      }

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpAt(const Size(390, 844));
      expect(find.text('第三方服务聚合广场'), findsOneWidget);
      expect(find.text('今日推荐入口'), findsOneWidget);
      expect(find.text('常用服务'), findsOneWidget);
      expect(find.text('求助'), findsOneWidget);
      expect(find.text('小灵 AI 陪伴'), findsOneWidget);
      expect(find.text('家政服务'), findsOneWidget);
      expect(find.text('医疗陪护'), findsOneWidget);
      expect(
        find.byKey(const Key('elderlyServiceGridSingleColumn')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('elderlyServiceGridMultiColumn')),
        findsNothing,
      );

      await pumpAt(const Size(1280, 900));
      expect(find.text('第三方服务聚合广场'), findsOneWidget);
      expect(find.text('今日推荐入口'), findsOneWidget);
      expect(find.text('常用服务'), findsOneWidget);
      expect(find.text('求助'), findsOneWidget);
      expect(find.text('小灵 AI 陪伴'), findsOneWidget);
      expect(find.text('家政服务'), findsOneWidget);
      expect(find.text('医疗陪护'), findsOneWidget);
      expect(
        find.byKey(const Key('elderlyServiceGridSingleColumn')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('elderlyServiceGridMultiColumn')),
        findsOneWidget,
      );
    },
  );

  testWidgets('elderly AI companion action routes directly to chat', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    final aiEntry = find.byKey(const Key('elderlyAiCompanionEntry'));
    await tester.ensureVisible(aiEntry);
    await tester.pumpAndSettle();
    await tester.tap(aiEntry.hitTestable());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chatInputField')), findsOneWidget);
    expect(find.byKey(const Key('sendMessageButton')), findsOneWidget);
  });

  testWidgets(
    'elderly care service entry opens service sheet and copies phone',
    (WidgetTester tester) async {
      await pumpAppToElderlyHome(tester);

      final serviceEntry = find.byKey(const Key('elderlyCareService家政服务'));
      await tester.ensureVisible(serviceEntry);
      await tester.pumpAndSettle();
      await tester.tap(serviceEntry.hitTestable());
      await tester.pumpAndSettle();

      expect(find.text('春和家政、安心到家等'), findsOneWidget);
      expect(find.text('12 家服务商'), findsOneWidget);
      expect(find.text('社区 3 公里内'), findsWidgets);
      expect(find.text('021-5600-2231'), findsOneWidget);
      expect(find.text('复制转接电话'), findsOneWidget);

      final copyButton = find.widgetWithText(OutlinedButton, '复制转接电话');
      final copyAction = tester.widget<OutlinedButton>(copyButton).onPressed;
      expect(copyAction, isNotNull);
      copyAction!.call();
      await tester.pumpAndSettle();

      expect(find.text('联系电话已复制'), findsOneWidget);
    },
  );

  testWidgets(
    'elderly help action opens support sheet and copies contact number',
    (WidgetTester tester) async {
      await pumpAppToElderlyHome(tester);

      final helpEntry = find.byKey(const Key('elderlyHelpEntry'));
      await tester.ensureVisible(helpEntry);
      await tester.pumpAndSettle();
      await tester.tap(helpEntry.hitTestable());
      await tester.pumpAndSettle();

      expect(find.text('您需要哪类帮助？'), findsOneWidget);
      expect(find.text('家人联系'), findsOneWidget);
      expect(find.text('社区服务'), findsOneWidget);
      expect(find.text('平台客服'), findsOneWidget);
      expect(find.text('复制号码'), findsWidgets);

      final copyButton = find.widgetWithText(TextButton, '复制号码').first;
      final copyAction = tester.widget<TextButton>(copyButton).onPressed;
      expect(copyAction, isNotNull);
      copyAction!.call();
      await tester.pumpAndSettle();

      expect(find.text('联系电话已复制'), findsOneWidget);
    },
  );
}
