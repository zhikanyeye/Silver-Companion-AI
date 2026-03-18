import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yinling_zhiban_demo/services/openrouter_client.dart';

void main() {
  test('sends model and messages and parses first response content', () async {
    late http.Request capturedRequest;

    final mockClient = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {
                'content': 'response text',
              },
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = OpenRouterClient(
      client: mockClient,
      proxyUri: Uri.parse('https://example.com/api/chat'),
    );
    final result = await client.createChatCompletion(
      model: 'test-model',
      messages: const [
        {'role': 'user', 'content': 'hi'},
        {'role': 'assistant', 'content': 'hello'},
      ],
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.toString(), 'https://example.com/api/chat');
    expect(capturedRequest.headers['Authorization'], isNull);
    final payload = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(payload['model'], 'test-model');
    expect(payload['messages'], isA<List<dynamic>>());
    expect((payload['messages'] as List<dynamic>), hasLength(2));
    final firstMessage = payload['messages'][0] as Map<String, dynamic>;
    expect(firstMessage['role'], 'user');
    expect(firstMessage['content'], 'hi');
    expect(result, 'response text');
  });

  test('includes status and body in non-2xx errors', () async {
    final mockClient = MockClient((request) async {
      return http.Response('bad response body', 500);
    });

    final client = OpenRouterClient(
      client: mockClient,
      proxyUri: Uri.parse('https://example.com/api/chat'),
    );

    expect(
      () => client.createChatCompletion(
        model: 'test-model',
        messages: const [
          {'role': 'user', 'content': 'hi'},
        ],
      ),
      throwsA(
        isA<StateError>()
            .having(
              (error) => error.message,
              'message',
              contains('500'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('bad response body'),
            ),
      ),
    );
  });

  test('throws StateError when response JSON is invalid', () async {
    final mockClient = MockClient((request) async {
      return http.Response('not-json', 200);
    });

    final client = OpenRouterClient(
      client: mockClient,
      proxyUri: Uri.parse('https://example.com/api/chat'),
    );

    expect(
      () => client.createChatCompletion(
        model: 'test-model',
        messages: const [
          {'role': 'user', 'content': 'hi'},
        ],
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('invalid JSON'),
        ),
      ),
    );
  });

  test('throws StateError when response JSON is not a map', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode(['not', 'a', 'map']),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = OpenRouterClient(
      client: mockClient,
      proxyUri: Uri.parse('https://example.com/api/chat'),
    );

    expect(
      () => client.createChatCompletion(
        model: 'test-model',
        messages: const [
          {'role': 'user', 'content': 'hi'},
        ],
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('invalid JSON shape'),
        ),
      ),
    );
  });

  test('throws StateError when response choices are empty', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({'choices': []}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = OpenRouterClient(
      client: mockClient,
      proxyUri: Uri.parse('https://example.com/api/chat'),
    );

    expect(
      () => client.createChatCompletion(
        model: 'test-model',
        messages: const [
          {'role': 'user', 'content': 'hi'},
        ],
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('missing choices'),
        ),
      ),
    );
  });

  test('throws StateError when response message is missing', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'choices': [
            {},
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = OpenRouterClient(
      client: mockClient,
      proxyUri: Uri.parse('https://example.com/api/chat'),
    );

    expect(
      () => client.createChatCompletion(
        model: 'test-model',
        messages: const [
          {'role': 'user', 'content': 'hi'},
        ],
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('missing message'),
        ),
      ),
    );
  });

  test('throws StateError when response content is missing', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {},
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = OpenRouterClient(
      client: mockClient,
      proxyUri: Uri.parse('https://example.com/api/chat'),
    );

    expect(
      () => client.createChatCompletion(
        model: 'test-model',
        messages: const [
          {'role': 'user', 'content': 'hi'},
        ],
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('missing content'),
        ),
      ),
    );
  });
}
