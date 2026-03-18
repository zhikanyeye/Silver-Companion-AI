import 'package:flutter_test/flutter_test.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_repository.dart';
import 'package:yinling_zhiban_demo/services/openrouter_client.dart';

class _FakeOpenRouterClient extends OpenRouterClient {
  _FakeOpenRouterClient({required this.response}) : super();

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
    final client = _FakeOpenRouterClient(response: 'proxy reply');
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
