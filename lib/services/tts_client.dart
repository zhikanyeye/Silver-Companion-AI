import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class TTSClient {
  TTSClient({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _baseUri = baseUri;

  final http.Client _client;
  Uri? _baseUri;

  void configureBaseUri(String? rawBaseUrl) {
    if (rawBaseUrl == null || rawBaseUrl.trim().isEmpty) {
      _baseUri = null;
      return;
    }
    _baseUri = Uri.parse(rawBaseUrl.trim());
  }

  bool get isConfigured => _baseUri != null;

  Future<Uint8List> synthesize({
    required String text,
    String voice = 'Bella',
    double speed = 1.0,
  }) async {
    final uri = _baseUri;
    if (uri == null) {
      throw StateError('TTS endpoint not configured');
    }

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'voice': voice, 'speed': speed}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('TTS request failed: ${response.statusCode} ${response.body}');
    }

    return response.bodyBytes;
  }
}
