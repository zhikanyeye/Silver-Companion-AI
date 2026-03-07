import 'dart:convert';

import 'package:http/http.dart' as http;

const String _openRouterApiKey =
    String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');

class OpenRouterClient {
  OpenRouterClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> createChatCompletion({
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    final response = await _client.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openRouterApiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('OpenRouter request failed: ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = payload['choices'] as List<dynamic>;
    final firstChoice = choices.first as Map<String, dynamic>;
    final message = firstChoice['message'] as Map<String, dynamic>;
    final content = message['content'];
    if (content is String) {
      return content;
    }

    throw StateError('OpenRouter response missing content');
  }
}
