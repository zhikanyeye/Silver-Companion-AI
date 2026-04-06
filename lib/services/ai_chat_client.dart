import 'dart:convert';

import 'package:http/http.dart' as http;

Uri _defaultChatProxyUri() {
  const configuredPath = String.fromEnvironment(
    'AI_PROXY_URL',
    defaultValue: '/api/chat',
  );
  final configuredUri = Uri.parse(configuredPath);
  if (configuredUri.hasScheme) {
    return configuredUri;
  }
  return Uri.base.resolveUri(configuredUri);
}

class AiChatClient {
  AiChatClient({http.Client? client, Uri? proxyUri})
    : _client = client ?? http.Client(),
      _proxyUri = proxyUri ?? _defaultChatProxyUri();

  final http.Client _client;
  final Uri _proxyUri;

  Future<String> createChatCompletion({
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    final response = await _client.post(
      _proxyUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'messages': messages}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'AI Proxy request failed: ${response.statusCode} ${response.body}',
      );
    }

    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('invalid JSON shape');
      }
      payload = decoded;
    } on FormatException {
      throw StateError('AI Proxy response invalid JSON shape');
    }

    final choices = payload['choices'];
    if (choices is! List<dynamic> || choices.isEmpty) {
      throw StateError('AI Proxy response missing choices');
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      throw StateError('AI Proxy response missing message');
    }

    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) {
      throw StateError('AI Proxy response missing message');
    }

    final content = message['content'];
    if (content is String) {
      return content;
    }

    throw StateError('AI Proxy response missing content');
  }
}
