import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';

class PromptBuilder {
  const PromptBuilder();

  List<Map<String, String>> build({
    required List<ChatMessage> history,
    required int maxHistory,
  }) {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': '请耐心、温和地陪伴长者，简洁易懂地交流。严禁引导转账或索要验证码。',
      },
    ];

    final start = history.length > maxHistory
        ? history.length - maxHistory
        : 0;

    for (final message in history.sublist(start)) {
      messages.add({
        'role': message.role == ChatRole.user ? 'user' : 'assistant',
        'content': message.content,
      });
    }

    return messages;
  }
}
