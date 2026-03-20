import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/elderly/elderly_home_page.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

import 'support/app_flow_test_helper.dart';

void main() {
  testWidgets('elderly route shows telecom-style service hub and avatar opens chat', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    expect(find.text('老人端'), findsOneWidget);
    expect(find.text('今日服务大厅'), findsOneWidget);
    expect(find.text('您好，今天想先用哪项服务？'), findsOneWidget);
    expect(find.text('常用服务'), findsOneWidget);
    expect(find.text('AI陪伴'), findsOneWidget);
    expect(find.text('一键求助'), findsOneWidget);
    expect(find.text('社区互助'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('活动'), 200);
    await tester.pumpAndSettle();

    expect(find.text('活动'), findsOneWidget);
    expect(find.text('小灵在线'), findsOneWidget);
    expect(find.byKey(const Key('childAvatarEntry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('childAvatarEntry')));
    await tester.pumpAndSettle();

    expect(find.text('AI智能助手'), findsOneWidget);
    expect(find.byKey(const Key('chatInputField')), findsOneWidget);
    expect(find.byKey(const Key('sendMessageButton')), findsOneWidget);
  });

  testWidgets('elderly community entry still routes to community feed', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    await tester.tap(find.text('社区互助'));
    await tester.pumpAndSettle();

    expect(find.text('社区互助'), findsWidgets);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('elderly home keeps primary service entries on small and wide screens', (
    WidgetTester tester,
  ) async {
    Future<void> pumpAt(Size size) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.highContrast(), home: const ElderlyHomePage()),
      );
      await tester.pumpAndSettle();
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAt(const Size(390, 844));
    expect(find.text('今日服务大厅'), findsOneWidget);
    expect(find.text('常用服务'), findsOneWidget);
    expect(find.text('一键求助'), findsOneWidget);
    expect(find.text('小灵在线'), findsOneWidget);
    expect(find.byKey(const Key('elderlyServiceGridSingleColumn')), findsOneWidget);
    expect(find.byKey(const Key('elderlyServiceGridMultiColumn')), findsNothing);

    await pumpAt(const Size(1280, 900));
    expect(find.text('今日服务大厅'), findsOneWidget);
    expect(find.text('常用服务'), findsOneWidget);
    expect(find.text('一键求助'), findsOneWidget);
    expect(find.text('小灵在线'), findsOneWidget);
    expect(find.byKey(const Key('elderlyServiceGridSingleColumn')), findsNothing);
    expect(find.byKey(const Key('elderlyServiceGridMultiColumn')), findsOneWidget);
  });

  testWidgets('elderly AI companion action shows coming soon feedback', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    await tester.tap(find.text('AI陪伴'));
    await tester.pump();

    expect(find.text('服务正在完善中'), findsOneWidget);
  });
}
