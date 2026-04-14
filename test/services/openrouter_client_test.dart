import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yinling/services/ai_chat_client.dart';

void main() {
  test('posts messages to proxy and parses first response content', () async {
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

    final client = AiChatClient(
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
    final payload = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(payload['messages'], isA<List<dynamic>>());
    expect(payload.containsKey('model'), isFalse);
    final firstMessage = payload['messages'][0] as Map<String, dynamic>;
    expect(firstMessage['role'], 'user');
    expect(firstMessage['content'], 'hi');
    expect(result, 'response text');
  });

  test('includes status and body in non-2xx errors', () async {
    final mockClient = MockClient((request) async {
      return http.Response('bad response body', 500);
    });

    final client = AiChatClient(
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
          allOf(contains('500'), contains('bad response body')),
        ),
      ),
    );
  });

  test('throws StateError when response JSON is invalid', () async {
    final mockClient = MockClient((request) async {
      return http.Response('not-json', 200);
    });

    final client = AiChatClient(
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

    final client = AiChatClient(
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

  test('throws StateError when response message or content is missing', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'choices': [
            {'message': {}},
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = AiChatClient(
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
