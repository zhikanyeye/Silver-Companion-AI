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

    final client = OpenRouterClient(client: mockClient);
    final result = await client.createChatCompletion(
      model: 'test-model',
      messages: const [
        {'role': 'user', 'content': 'hi'},
        {'role': 'assistant', 'content': 'hello'},
      ],
    );

    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url.toString(),
      'https://openrouter.ai/api/v1/chat/completions',
    );
    final payload = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(payload['model'], 'test-model');
    expect(payload['messages'], isA<List<dynamic>>());
    expect((payload['messages'] as List<dynamic>), hasLength(2));
    final firstMessage = payload['messages'][0] as Map<String, dynamic>;
    expect(firstMessage['role'], 'user');
    expect(firstMessage['content'], 'hi');
    expect(result, 'response text');
  });
}
