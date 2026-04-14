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
    expect(find.text('今日服务大厅'), findsOneWidget);
    expect(find.text('今日重点服务'), findsOneWidget);
    expect(find.text('今天想先使用哪项服务？'), findsOneWidget);
    expect(find.text('常用服务'), findsOneWidget);
    expect(find.text('AI陪伴'), findsOneWidget);
    expect(find.text('求助'), findsOneWidget);
    expect(find.text('社区'), findsOneWidget);
    expect(find.text('活动'), findsOneWidget);
    expect(find.text('小灵在线'), findsOneWidget);
    expect(find.byKey(const Key('childAvatarEntry')), findsOneWidget);

    final avatarEntry = find.byKey(const Key('childAvatarEntry'));
    await tester.ensureVisible(avatarEntry);
    await tester.pumpAndSettle();
    await tester.tap(avatarEntry.hitTestable());
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
      expect(find.text('今日服务大厅'), findsOneWidget);
      expect(find.text('今日重点服务'), findsOneWidget);
      expect(find.text('常用服务'), findsOneWidget);
      expect(find.text('求助'), findsOneWidget);
      expect(find.text('小灵在线'), findsOneWidget);
      expect(
        find.byKey(const Key('elderlyServiceGridSingleColumn')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('elderlyServiceGridMultiColumn')),
        findsNothing,
      );

      await pumpAt(const Size(1280, 900));
      expect(find.text('今日服务大厅'), findsOneWidget);
      expect(find.text('今日重点服务'), findsOneWidget);
      expect(find.text('常用服务'), findsOneWidget);
      expect(find.text('求助'), findsOneWidget);
      expect(find.text('小灵在线'), findsOneWidget);
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
