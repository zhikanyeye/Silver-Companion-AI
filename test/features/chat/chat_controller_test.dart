import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/features/chat/chat_controller.dart';
import 'package:yinling_zhiban_demo/features/chat/memory_store.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';

class _TestMemoryStore extends MemoryStore {
  @override
  Future<List<String>> load() async => <String>[];

  @override
  Future<void> save(List<String> memory) async {}
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
}
