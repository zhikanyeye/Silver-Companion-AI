import 'package:flutter_test/flutter_test.dart';
import 'package:yinling/features/chat/chat_repository.dart';
import 'package:yinling/services/ai_chat_client.dart';

class _FakeAiChatClient extends AiChatClient {
  _FakeAiChatClient({required this.response}) : super();

  final String response;
  String? capturedModel;
  List<Map<String, String>>? capturedMessages;

  @override
  Future<String> createChatCompletion({
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    capturedModel = model;
    capturedMessages = messages;
    return response;
  }
}

void main() {
  test('forwards model and messages to client and returns response text', () async {
    final client = _FakeAiChatClient(response: 'proxy reply');
    final repository = ChatRepository(client: client);

    final result = await repository.sendMessage(
      model: 'proxy-model',
      messages: const [
        {'role': 'user', 'content': 'hello'},
        {'role': 'assistant', 'content': 'hi'},
      ],
    );

    expect(client.capturedModel, 'proxy-model');
    expect(
      client.capturedMessages,
      const [
        {'role': 'user', 'content': 'hello'},
        {'role': 'assistant', 'content': 'hi'},
      ],
    );
    expect(result, 'proxy reply');
  });
}
