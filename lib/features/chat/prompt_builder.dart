import 'package:yinling_zhiban_demo/features/chat/assistant_role_profile.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';

class PromptBuilder {
  const PromptBuilder();

  List<Map<String, String>> build({
    required List<ChatMessage> history,
    required int maxHistory,
  }) {
    final safeMaxHistory = maxHistory < 0 ? 0 : maxHistory;
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': silverCompanionAssistantRole},
    ];

    final start = history.length > safeMaxHistory
        ? history.length - safeMaxHistory
        : 0;

    for (final message in history.sublist(start)) {
      final role = switch (message.role) {
        ChatRole.user => 'user',
        ChatRole.assistant => 'assistant',
        ChatRole.system => 'system',
      };
      messages.add({'role': role, 'content': message.content});
    }

    return messages;
  }
}
