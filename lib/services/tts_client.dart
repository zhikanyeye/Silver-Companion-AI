import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

Uri _defaultTtsProxyUri() {
  const configuredPath = String.fromEnvironment(
    'TTS_PROXY_URL',
    defaultValue: '/api/tts',
  );
  final configuredUri = Uri.parse(configuredPath);
  if (configuredUri.hasScheme) {
    return configuredUri;
  }
  return Uri.base.resolveUri(configuredUri);
}

/// TTS client that interacts with the Cloudflare Pages Function proxy (`/api/tts`).
/// The actual EdgeTTS /v1/audio/speech request and API Key handling is done safely on the server side.
class TTSClient {
  TTSClient({http.Client? client, Uri? proxyUri})
    : _client = client ?? http.Client(),
      _proxyUri = proxyUri ?? _defaultTtsProxyUri();

  final http.Client _client;
  final Uri _proxyUri;

  // We consider it always configured since we rely on the relative `/api/tts` path.
  // The backend will return a 500 error if Cloudflare env variables aren't set.
  bool get isConfigured => true;

  /// Synthesize speech via the `/api/tts` proxy.
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
    final response = await _client.post(
      _proxyUri,
      headers: {'Content-Type': 'application/json'},
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
