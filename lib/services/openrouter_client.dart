import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const String _openRouterApiKeyZoneKey = 'openrouter_api_key';

String _resolveOpenRouterApiKey() {
  final zoneValue = Zone.current[_openRouterApiKeyZoneKey];
  if (zoneValue is String) {
    return zoneValue;
  }

  return const String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
}

class OpenRouterClient {
  OpenRouterClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> createChatCompletion({
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    final apiKey = _resolveOpenRouterApiKey();
    if (apiKey.isEmpty) {
      throw StateError('OPENROUTER_API_KEY is required for OpenRouter requests');
    }

    final response = await _client.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'OpenRouter request failed: ${response.statusCode} ${response.body}',
      );
    }

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw StateError('OpenRouter response invalid JSON');
    }

    final choices = payload['choices'];
    if (choices is! List<dynamic> || choices.isEmpty) {
      throw StateError('OpenRouter response missing choices');
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      throw StateError('OpenRouter response missing message');
    }

    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) {
      throw StateError('OpenRouter response missing message');
    }

    final content = message['content'];
    if (content is String) {
      return content;
    }

    throw StateError('OpenRouter response missing content');
  }
}
