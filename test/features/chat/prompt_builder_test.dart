import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';
import 'package:yinling_zhiban_demo/features/chat/prompt_builder.dart';

void main() {
  test('builds system message with empathy and anti-fraud plus last history', () {
    const builder = PromptBuilder();
    final history = <ChatMessage>[
      const ChatMessage(role: ChatRole.user, content: '你好'),
      const ChatMessage(role: ChatRole.assistant, content: '您好'),
      const ChatMessage(role: ChatRole.user, content: '我想去散步'),
    ];

    final messages = builder.build(history: history, maxHistory: 2);

    expect(messages.first['role'], 'system');
    expect(messages.first['content'], contains('请耐心、温和地陪伴长者'));
    expect(messages.first['content'], contains('严禁引导转账或索要验证码'));
    expect(messages, hasLength(3));
    expect(messages[1]['role'], 'assistant');
    expect(messages[1]['content'], '您好');
    expect(messages[2]['role'], 'user');
    expect(messages[2]['content'], '我想去散步');
  });
}
