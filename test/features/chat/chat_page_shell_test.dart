import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling/features/chat/chat_controller.dart';
import 'package:yinling/features/chat/chat_page.dart';
import 'package:yinling/theme/app_theme.dart';

void main() {
  testWidgets('chat page exposes unified service shell markers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.highContrast(), home: const ChatPage()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chatServiceShell')), findsOneWidget);
    expect(find.text('AI 助手'), findsOneWidget);
    expect(find.byKey(const Key('chatSpeechToggle')), findsOneWidget);
    expect(find.byKey(const Key('chatInputField')), findsOneWidget);
    expect(find.byKey(const Key('sendMessageButton')), findsOneWidget);
    expect(find.byKey(const Key('chatReplayLastAssistantButton')), findsNothing);
  });

  testWidgets('chat messages expose copy actions', (WidgetTester tester) async {
    final controller = ChatController();
    controller.debugAddAssistantMessage('这是一条可以复制的回复');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: ChatPage(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('这是一条可以复制的回复'), findsOneWidget);
    expect(find.byType(SelectableText), findsWidgets);
    expect(find.byKey(const Key('chatCopyLastAssistantButton')), findsOneWidget);
    expect(find.byKey(const Key('chatReplayLastAssistantButton')), findsOneWidget);
  });
}
