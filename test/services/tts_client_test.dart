import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:yinling/services/tts_client.dart';

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _handler(request);
}

void main() {
  test('posts text to tts proxy and returns audio bytes', () async {
    late http.BaseRequest capturedRequest;
    final client = _FakeHttpClient((request) async {
      capturedRequest = request;
      return http.StreamedResponse(
        Stream.value(Uint8List.fromList([1, 2, 3, 4])),
        200,
        headers: {'content-type': 'audio/mpeg'},
      );
    });

    final ttsClient = TTSClient(
      client: client,
      proxyUri: Uri.parse('https://tts.example.com/tts'),
    );
    final audio = await ttsClient.synthesize(
      text: '您好，今天感觉怎么样？',
      voice: 'Bella',
      speed: 1.0,
    );

    expect(audio, Uint8List.fromList([1, 2, 3, 4]));
    expect(capturedRequest.url.toString(), 'https://tts.example.com/tts');
    final body = jsonDecode((capturedRequest as http.Request).body) as Map<String, dynamic>;
    expect(body['model'], 'tts-1');
    expect(body['input'], '您好，今天感觉怎么样？');
    expect(body['voice'], 'Bella');
    expect(body['response_format'], 'mp3');
  });

  test('throws safe error when tts proxy fails', () async {
    final client = _FakeHttpClient((request) async {
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"error":"down"}')),
        503,
        headers: {'content-type': 'application/json'},
      );
    });

    final ttsClient = TTSClient(
      client: client,
      proxyUri: Uri.parse('https://tts.example.com/tts'),
    );

    expect(
      () => ttsClient.synthesize(text: '您好', voice: 'Bella', speed: 1.0),
      throwsA(isA<StateError>()),
    );
  });
}
