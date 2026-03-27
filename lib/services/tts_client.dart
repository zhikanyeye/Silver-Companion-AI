import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// TTS client compatible with OpenAI /v1/audio/speech API format.
/// Works with EdgeTTS Cloudflare Workers or any OpenAI-compatible TTS endpoint.
class TTSClient {
  TTSClient({http.Client? client, Uri? baseUri, String? apiKey})
    : _client = client ?? http.Client(),
      _baseUri = baseUri,
      _apiKey = apiKey;

  final http.Client _client;
  Uri? _baseUri;
  String? _apiKey;

  void configureBaseUri(String? rawBaseUrl) {
    if (rawBaseUrl == null || rawBaseUrl.trim().isEmpty) {
      _baseUri = null;
      return;
    }
    _baseUri = Uri.parse(rawBaseUrl.trim());
  }

  void configureApiKey(String? key) {
    _apiKey = (key != null && key.trim().isNotEmpty) ? key.trim() : null;
  }

  bool get isConfigured => _baseUri != null;

  /// Synthesize speech using OpenAI-compatible /v1/audio/speech API.
  ///
  /// [text] - The text to convert to speech.
  /// [voice] - Voice name (e.g., 'shimmer', 'alloy', 'zh-CN-XiaoxiaoNeural').
  /// [speed] - Playback speed (0.5 to 2.0).
  /// [format] - Output format: 'mp3', 'wav', 'ogg'.
  Future<Uint8List> synthesize({
    required String text,
    String voice = 'shimmer',
    double speed = 1.0,
    String format = 'mp3',
  }) async {
    final uri = _baseUri;
    if (uri == null) {
      throw StateError('TTS endpoint not configured');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_apiKey != null) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }

    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'model': 'tts-1',
        'input': text,
        'voice': voice,
        'speed': speed,
        'response_format': format,
        'stream': false,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('TTS request failed: ${response.statusCode} ${response.body}');
    }

    return response.bodyBytes;
  }
}
