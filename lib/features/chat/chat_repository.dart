import 'package:yinling_zhiban_demo/services/ai_chat_client.dart';

class ChatRepository {
  ChatRepository({AiChatClient? client})
      : _client = client ?? AiChatClient();

  final AiChatClient _client;

  Future<String> sendMessage({
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    return _client.createChatCompletion(model: model, messages: messages);
  }
}
