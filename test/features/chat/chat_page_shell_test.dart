import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
