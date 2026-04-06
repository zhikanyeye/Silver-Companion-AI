import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/elderly/elderly_home_page.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

import 'support/app_flow_test_helper.dart';

void main() {
  testWidgets('elderly route shows service hub and avatar opens chat', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    expect(find.text('Elderly Home'), findsOneWidget);
    expect(find.text('Today Service Hall'), findsOneWidget);
    expect(find.text('Today key services'), findsOneWidget);
    expect(find.text('What would you like to use first today?'), findsOneWidget);
    expect(find.text('Common services'), findsOneWidget);
    expect(find.text('AI Companion'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Activities'), findsOneWidget);
    expect(find.text('Xiao Ling Online'), findsOneWidget);
    expect(find.byKey(const Key('childAvatarEntry')), findsOneWidget);

    final avatarEntry = find.byKey(const Key('childAvatarEntry'));
    await tester.ensureVisible(avatarEntry);
    await tester.pumpAndSettle();
    await tester.tap(avatarEntry.hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('AI Assistant'), findsOneWidget);
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

    expect(find.text('Community Board'), findsWidgets);
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
    expect(find.text('Today Service Hall'), findsOneWidget);
    expect(find.text('Today key services'), findsOneWidget);
    expect(find.text('Common services'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Xiao Ling Online'), findsOneWidget);
    expect(find.byKey(const Key('elderlyServiceGridSingleColumn')), findsOneWidget);
    expect(find.byKey(const Key('elderlyServiceGridMultiColumn')), findsNothing);

    await pumpAt(const Size(1280, 900));
    expect(find.text('Today Service Hall'), findsOneWidget);
    expect(find.text('Today key services'), findsOneWidget);
    expect(find.text('Common services'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Xiao Ling Online'), findsOneWidget);
    expect(find.byKey(const Key('elderlyServiceGridSingleColumn')), findsNothing);
    expect(find.byKey(const Key('elderlyServiceGridMultiColumn')), findsOneWidget);
  });

  testWidgets('elderly AI companion action routes directly to chat', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    final aiEntry = find.byKey(const Key('elderlyAiCompanionEntry'));
    await tester.ensureVisible(aiEntry);
    await tester.pumpAndSettle();
    await tester.tap(aiEntry.hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.byKey(const Key('chatInputField')), findsOneWidget);
    expect(find.byKey(const Key('sendMessageButton')), findsOneWidget);
  });

  testWidgets('elderly help action opens support sheet and copies contact number', (
    WidgetTester tester,
  ) async {
    await pumpAppToElderlyHome(tester);

    final helpEntry = find.byKey(const Key('elderlyHelpEntry'));
    await tester.ensureVisible(helpEntry);
    await tester.pumpAndSettle();
    await tester.tap(helpEntry.hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('What kind of help do you need?'), findsOneWidget);
    expect(find.text('Family contact'), findsOneWidget);
    expect(find.text('Community service'), findsOneWidget);
    expect(find.text('Platform support'), findsOneWidget);
    expect(find.text('Copy number'), findsWidgets);

    final copyButton = find.widgetWithText(TextButton, 'Copy number').first;
    final copyAction = tester.widget<TextButton>(copyButton).onPressed;
    expect(copyAction, isNotNull);
    copyAction!.call();
    await tester.pumpAndSettle();

    expect(find.text('Contact number copied'), findsOneWidget);
  });
}
