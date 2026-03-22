import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/chat/chat_controller.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_repository.dart';
import 'package:yinling_zhiban_demo/features/chat/memory_store.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';

class _TestMemoryStore extends MemoryStore {
  @override
  Future<List<String>> load() async => <String>[];

  @override
  Future<void> save(List<String> memory) async {}
}

class _FakeChatRepository extends ChatRepository {
  _FakeChatRepository({this.reply = 'assistant reply', this.errorToThrow});

  final String reply;
  final Object? errorToThrow;

  @override
  Future<String> sendMessage({
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return reply;
  }
}

class _RecordingSpeechService extends WebSpeechService {
  _RecordingSpeechService({this.supported = true})
    : super(
        isWeb: () => true,
        isSpeechSupportedOnWeb: () => supported,
        speakOnWeb: (text) {},
      );

  final bool supported;
  final List<String> spokenTexts = [];

  @override
  void speak(String text) {
    spokenTexts.add(text);
  }
}

void main() {
  test('startRecognition keeps recognizing false when unsupported', () {
    final speechService = WebSpeechService(
      isWeb: () => false,
      startRecognitionOnWeb: () {
        throw StateError('should not be called when unsupported');
      },
    );
    final controller = ChatController(
      speechService: speechService,
      memoryStore: _TestMemoryStore(),
    );

    controller.startRecognition();

    expect(controller.isRecognizing, isFalse);
  });

  test('start and stop recognition toggles recognizing when supported', () {
    var startCalls = 0;
    var stopCalls = 0;
    final speechService = WebSpeechService(
      isWeb: () => true,
      isSpeechSupportedOnWeb: () => true,
      startRecognitionOnWeb: () {
        startCalls += 1;
      },
      stopRecognitionOnWeb: () {
        stopCalls += 1;
      },
    );
    final controller = ChatController(
      speechService: speechService,
      memoryStore: _TestMemoryStore(),
    );

    controller.startRecognition();
    expect(controller.isRecognizing, isTrue);

    controller.stopRecognition();
    expect(controller.isRecognizing, isFalse);

    expect(startCalls, 1);
    expect(stopCalls, 1);
  });

  test('sendText maps proxy not configured failures to safe service message', () async {
    final controller = ChatController(
      repository: _FakeChatRepository(
        errorToThrow: StateError(
          'OpenRouter request failed: 404 proxy route missing at https://proxy.example.com/api/chat',
        ),
      ),
      memoryStore: _TestMemoryStore(),
    );

    await controller.sendText('hello');

    expect(controller.error, 'AI 服务配置不可用，请稍后再试');
    expect(controller.error, isNot(contains('proxy.example.com')));
    expect(controller.error, isNot(contains('OpenRouter request failed')));
    expect(controller.messages, hasLength(1));
  });

  test('sendText maps 400 failures to safe invalid request message', () async {
    final controller = ChatController(
      repository: _FakeChatRepository(
        errorToThrow: StateError(
          'OpenRouter request failed: 400 invalid model sk-test-key https://api.example.com/v1/chat',
        ),
      ),
      memoryStore: _TestMemoryStore(),
    );

    await controller.sendText('hello');

    expect(controller.error, '请求内容无效，请修改后重试');
    expect(controller.error, isNot(contains('sk-test-key')));
    expect(controller.error, isNot(contains('api.example.com')));
    expect(controller.error, isNot(contains('400')));
  });

  test('sendText maps upstream unavailable failures to temporary service message', () async {
    final controller = ChatController(
      repository: _FakeChatRepository(
        errorToThrow: StateError(
          'OpenRouter request failed: 504 upstream timeout at https://proxy.example.com/api/chat',
        ),
      ),
      memoryStore: _TestMemoryStore(),
    );

    await controller.sendText('hello');

    expect(controller.error, 'AI 服务暂时不可用，请稍后再试');
    expect(controller.error, isNot(contains('proxy.example.com')));
    expect(controller.error, isNot(contains('upstream')));
    expect(controller.error, isNot(contains('504')));
  });

  test('sendText keeps success behavior intact', () async {
    final speechService = _RecordingSpeechService();
    final controller = ChatController(
      repository: _FakeChatRepository(reply: 'assistant ok'),
      speechService: speechService,
      memoryStore: _TestMemoryStore(),
    );

    await controller.sendText('hello');

    expect(controller.error, isNull);
    expect(controller.messages, hasLength(2));
    expect(controller.messages.first.content, 'hello');
    expect(controller.messages.last.content, 'assistant ok');
    expect(speechService.spokenTexts, ['assistant ok']);
  });

  test('can replay last assistant message when speech is enabled', () {
    final speechService = _RecordingSpeechService();
    final controller = ChatController(
      speechService: speechService,
      memoryStore: _TestMemoryStore(),
    );

    controller.debugAddAssistantMessage('再次问候');
    controller.replayLastAssistantMessage();

    expect(speechService.spokenTexts, ['再次问候']);
  });
}
