import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/chat/assistant_role_profile.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';
import 'package:yinling_zhiban_demo/features/chat/prompt_builder.dart';

void main() {
  test('builds project role prompt and keeps latest history entries', () {
    const builder = PromptBuilder();
    final history = <ChatMessage>[
      const ChatMessage(role: ChatRole.user, content: '你好'),
      const ChatMessage(role: ChatRole.assistant, content: '您好，我在这里陪您聊天。'),
      const ChatMessage(role: ChatRole.user, content: '我想出去散步'),
    ];

    final messages = builder.build(history: history, maxHistory: 2);

    expect(messages.first['role'], 'system');
    expect(messages.first['content'], silverCompanionAssistantRole);
    expect(messages.first['content'], contains('银聆'));
    expect(messages.first['content'], contains('严禁引导转账'));
    expect(messages.first['content'], contains('验证码'));
    expect(messages, hasLength(3));
    expect(messages[1]['role'], 'assistant');
    expect(messages[1]['content'], '您好，我在这里陪您聊天。');
    expect(messages[2]['role'], 'user');
    expect(messages[2]['content'], '我想出去散步');
  });

  test('returns only system message when history is empty', () {
    const builder = PromptBuilder();

    final messages = builder.build(history: const [], maxHistory: 5);

    expect(messages, hasLength(1));
    expect(messages.first['role'], 'system');
    expect(messages.first['content'], silverCompanionAssistantRole);
  });

  test('returns only system message when maxHistory is zero', () {
    const builder = PromptBuilder();
    final history = <ChatMessage>[
      const ChatMessage(role: ChatRole.user, content: '你好'),
      const ChatMessage(role: ChatRole.assistant, content: '您好'),
    ];

    final messages = builder.build(history: history, maxHistory: 0);

    expect(messages, hasLength(1));
    expect(messages.first['role'], 'system');
    expect(messages.first['content'], silverCompanionAssistantRole);
  });

  test('maps system role explicitly', () {
    const builder = PromptBuilder();
    final history = <ChatMessage>[
      const ChatMessage(role: ChatRole.system, content: '系统提示'),
    ];

    final messages = builder.build(history: history, maxHistory: 1);

    expect(messages, hasLength(2));
    expect(messages[1]['role'], 'system');
    expect(messages[1]['content'], '系统提示');
  });
}
