import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_controller.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_repository.dart';
import 'package:yinling_zhiban_demo/features/chat/memory_store.dart';
import 'package:yinling_zhiban_demo/services/audio_playback_service.dart';
import 'package:yinling_zhiban_demo/services/demo_identity_store.dart';
import 'package:yinling_zhiban_demo/services/tts_client.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';

class _TestMemoryStore extends MemoryStore {
  @override
  Future<List<String>> load() async => <String>[];

  @override
  Future<void> save(List<String> memory) async {}
}

class _FakeIdentityStore extends DemoIdentityStore {
  @override
  Future<DemoIdentity> loadOrCreate() async {
    return const DemoIdentity(
      actorId: 'guest-test',
      displayName: 'Test User',
      identityLabel: 'Resident',
    );
  }
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
  _RecordingSpeechService({
    this.recognitionSupported = true,
    this.playbackSupported = true,
    this.startSucceeds = true,
  }) : super(
         isWeb: () => true,
         isRecognitionSupportedOnWeb: () => recognitionSupported,
         isPlaybackSupportedOnWeb: () => playbackSupported,
         startRecognitionOnWeb: () => startSucceeds,
         speakOnWeb: (text) {},
       );

  final bool recognitionSupported;
  final bool playbackSupported;
  final bool startSucceeds;
  final List<String> spokenTexts = <String>[];

  void Function()? onStartCallback;
  void Function(String)? onInterimCallback;
  void Function(String)? onFinalCallback;
  void Function(String)? onErrorCallback;
  void Function()? onEndCallback;

  @override
  void setRecognitionCallbacks({
    required void Function() onStart,
    required void Function(String) onInterim,
    required void Function(String) onFinal,
    required void Function(String) onError,
    required void Function() onEnd,
  }) {
    onStartCallback = onStart;
    onInterimCallback = onInterim;
    onFinalCallback = onFinal;
    onErrorCallback = onError;
    onEndCallback = onEnd;
  }

  @override
  void speak(String text) {
    spokenTexts.add(text);
  }
}

class _FakeTTSClient extends TTSClient {
  _FakeTTSClient({this.shouldThrow = false})
    : super(proxyUri: Uri.parse('https://tts.example.com/tts'));

  final bool shouldThrow;
  final List<int> audio = const <int>[1, 2, 3];
  int calls = 0;

  @override
  Future<Uint8List> synthesize({
    required String text,
    String voice = 'Bella',
    double speed = 1.0,
    String format = 'mp3',
  }) async {
    calls += 1;
    if (shouldThrow) {
      throw StateError('tts failed');
    }
    return Uint8List.fromList(audio);
  }
}

class _RecordingAudioPlaybackService extends AudioPlaybackService {
  _RecordingAudioPlaybackService({this.supported = true})
    : super(
        isWeb: () => true,
        isPlaybackSupportedOnWeb: () => supported,
        playBytesOnWeb: (bytes, mimeType) async {},
      );

  final bool supported;
  final List<Uint8List> playedAudio = <Uint8List>[];

  @override
  Future<void> playBytes(
    Uint8List bytes, {
    String mimeType = 'audio/wav',
  }) async {
    playedAudio.add(bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ChatController createController({
    ChatRepository? repository,
    WebSpeechService? speechService,
    TTSClient? ttsClient,
    AudioPlaybackService? audioPlaybackService,
  }) {
    return ChatController(
      repository: repository,
      speechService: speechService,
      ttsClient: ttsClient,
      audioPlaybackService: audioPlaybackService,
      memoryStore: _TestMemoryStore(),
      identityStore: _FakeIdentityStore(),
    );
  }

  test('startRecognition keeps recognizing false when unsupported', () {
    final speechService = WebSpeechService(
      isWeb: () => false,
      startRecognitionOnWeb: () {
        throw StateError('should not be called when unsupported');
      },
    );
    final controller = createController(speechService: speechService);

    controller.startRecognition();

    expect(controller.isRecognizing, isFalse);
  });

  test('start and stop recognition toggles recognizing when supported', () {
    var startCalls = 0;
    var stopCalls = 0;
    final speechService = WebSpeechService(
      isWeb: () => true,
      isRecognitionSupportedOnWeb: () => true,
      startRecognitionOnWeb: () {
        startCalls += 1;
        return true;
      },
      stopRecognitionOnWeb: () {
        stopCalls += 1;
      },
    );
    final controller = createController(speechService: speechService);

    controller.startRecognition();
    expect(controller.isRecognizing, isTrue);

    controller.stopRecognition();
    expect(controller.isRecognizing, isFalse);

    expect(startCalls, 1);
    expect(stopCalls, 1);
  });

  test('startRecognition keeps recognizing false when web start fails', () {
    final speechService = WebSpeechService(
      isWeb: () => true,
      isRecognitionSupportedOnWeb: () => true,
      startRecognitionOnWeb: () => false,
    );
    final controller = createController(speechService: speechService);

    controller.startRecognition();

    expect(controller.isRecognizing, isFalse);
    expect(controller.error, '语音输入启动失败，请检查麦克风权限后重试。');
  });

  test(
    'speech callbacks are registered immediately on controller creation',
    () {
      final speechService = _RecordingSpeechService();

      createController(speechService: speechService);

      expect(speechService.onStartCallback, isNotNull);
      expect(speechService.onInterimCallback, isNotNull);
      expect(speechService.onFinalCallback, isNotNull);
      expect(speechService.onErrorCallback, isNotNull);
      expect(speechService.onEndCallback, isNotNull);
    },
  );

  test('speech error callback maps no-speech to user-friendly message', () {
    final speechService = _RecordingSpeechService();
    final controller = createController(speechService: speechService);

    speechService.onErrorCallback?.call('no-speech');

    expect(
      controller.error,
      '\u6ca1\u6709\u8bc6\u522b\u5230\u8bed\u97f3\uff0c\u8bf7\u9760\u8fd1\u9ea6\u514b\u98ce\u540e\u518d\u8bd5\u4e00\u6b21\u3002',
    );
  });

  test('speech input and output capabilities are separated', () {
    final speechService = _RecordingSpeechService(
      recognitionSupported: false,
      playbackSupported: true,
    );
    final controller = createController(speechService: speechService);

    expect(controller.isSpeechInputSupported, isFalse);
    expect(controller.isSpeechOutputSupported, isTrue);
  });

  test(
    'sendText maps proxy not configured failures to safe service message',
    () async {
      final controller = createController(
        repository: _FakeChatRepository(
          errorToThrow: StateError(
            'OpenRouter request failed: 404 proxy route missing at https://proxy.example.com/api/chat',
          ),
        ),
      );

      await controller.sendText('hello');

      expect(
        controller.error,
        'AI service configuration is unavailable. Please try again later.',
      );
      expect(controller.error, isNot(contains('proxy.example.com')));
      expect(controller.error, isNot(contains('OpenRouter request failed')));
      expect(controller.messages, hasLength(1));
    },
  );

  test('sendText maps 400 failures to safe invalid request message', () async {
    final controller = createController(
      repository: _FakeChatRepository(
        errorToThrow: StateError(
          'OpenRouter request failed: 400 invalid model sk-test-key https://api.example.com/v1/chat',
        ),
      ),
    );

    await controller.sendText('hello');

    expect(
      controller.error,
      'Request content is invalid. Please revise it and try again.',
    );
    expect(controller.error, isNot(contains('sk-test-key')));
    expect(controller.error, isNot(contains('api.example.com')));
    expect(controller.error, isNot(contains('400')));
  });

  test(
    'sendText maps upstream unavailable failures to temporary service message',
    () async {
      final controller = createController(
        repository: _FakeChatRepository(
          errorToThrow: StateError(
            'OpenRouter request failed: 504 upstream timeout at https://proxy.example.com/api/chat',
          ),
        ),
      );

      await controller.sendText('hello');

      expect(
        controller.error,
        'AI service is temporarily unavailable. Please try again later.',
      );
      expect(controller.error, isNot(contains('proxy.example.com')));
      expect(controller.error, isNot(contains('upstream')));
      expect(controller.error, isNot(contains('504')));
    },
  );

  test('sendText keeps success behavior intact', () async {
    final speechService = _RecordingSpeechService();
    final ttsClient = _FakeTTSClient();
    final audioPlaybackService = _RecordingAudioPlaybackService();
    final controller = createController(
      repository: _FakeChatRepository(reply: 'assistant ok'),
      speechService: speechService,
      ttsClient: ttsClient,
      audioPlaybackService: audioPlaybackService,
    );

    await controller.sendText('hello');

    expect(controller.error, isNull);
    expect(controller.messages, hasLength(2));
    expect(controller.messages.first.content, 'hello');
    expect(controller.messages.last.content, 'assistant ok');
    expect(ttsClient.calls, 1);
    expect(audioPlaybackService.playedAudio, <Uint8List>[
      Uint8List.fromList(<int>[1, 2, 3]),
    ]);
    expect(speechService.spokenTexts, isEmpty);
  });

  test('sendText falls back to browser speech when TTS client fails', () async {
    final speechService = _RecordingSpeechService();
    final ttsClient = _FakeTTSClient(shouldThrow: true);
    final audioPlaybackService = _RecordingAudioPlaybackService();
    final controller = createController(
      repository: _FakeChatRepository(reply: 'assistant ok'),
      speechService: speechService,
      ttsClient: ttsClient,
      audioPlaybackService: audioPlaybackService,
    );

    await controller.sendText('hello');

    expect(ttsClient.calls, 1);
    expect(audioPlaybackService.playedAudio, isEmpty);
    expect(speechService.spokenTexts, <String>['assistant ok']);
  });

  test('can replay last assistant message when speech is enabled', () async {
    final speechService = _RecordingSpeechService();
    final controller = createController(speechService: speechService);

    controller.debugAddAssistantMessage('replay me');
    await controller.replayLastAssistantMessage();

    expect(speechService.spokenTexts, <String>['replay me']);
  });
}
