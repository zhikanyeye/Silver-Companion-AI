import 'package:yinling_zhiban_demo/services/openrouter_client.dart';

class ChatRepository {
  ChatRepository({OpenRouterClient? client})
      : _client = client ?? OpenRouterClient();

  final OpenRouterClient _client;

  Future<String> sendMessage({
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    return _client.createChatCompletion(model: model, messages: messages);
  }
}
