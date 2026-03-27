import 'package:flutter/foundation.dart';

import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_repository.dart';
import 'package:yinling_zhiban_demo/features/chat/prompt_builder.dart';
import 'package:yinling_zhiban_demo/features/chat/scam_rules.dart';
import 'package:yinling_zhiban_demo/services/audio_playback_service.dart';
import 'package:yinling_zhiban_demo/services/tts_client.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';
import 'package:yinling_zhiban_demo/config/app_config.dart';
import 'package:yinling_zhiban_demo/config/config_loader.dart';
import 'package:yinling_zhiban_demo/features/chat/memory_store.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    ChatRepository? repository,
    PromptBuilder? promptBuilder,
    WebSpeechService? speechService,
    TTSClient? ttsClient,
    AudioPlaybackService? audioPlaybackService,
    MemoryStore? memoryStore,
    String? model,
    this.maxHistory = 12,
  })  : _repository = repository ?? ChatRepository(),
        _promptBuilder = promptBuilder ?? const PromptBuilder(),
        _speechService = speechService ?? WebSpeechService(),
        _ttsClient = ttsClient ?? TTSClient(),
        _audioPlaybackService = audioPlaybackService ?? AudioPlaybackService(),
        _memoryStore = memoryStore ?? MemoryStore(),
        _model = model ?? 'openai/gpt-4o-mini' {
  // Initialize memory asynchronously (best-effort)
  _loadMemory();
}

  final ChatRepository _repository;
  final PromptBuilder _promptBuilder;
  final WebSpeechService _speechService;
  final TTSClient _ttsClient;
  final AudioPlaybackService _audioPlaybackService;
  String _model;
  String get model => _model;
  final int maxHistory;

  final List<ChatMessage> _messages = <ChatMessage>[];
  final MemoryStore _memoryStore;
  List<String> _memory = [];

  // Callback for populating the input text field from speech recognition
  void Function(String text)? onInterimText;
  void Function(String text)? onFinalText;

  Future<void> _loadMemory() async {
    _memory = await _memoryStore.load();
    _speechService.setRecognitionCallbacks(
      onInterim: (text) {
        onInterimText?.call(text);
      },
      onFinal: (text) {
        onFinalText?.call(text);
      },
      onEnd: () {
        if (isRecognizing) {
          isRecognizing = false;
          notifyListeners();
        }
      },
    );
    notifyListeners();
  }

  // Optional: expose a config loader (phase 3 integration)
  final ConfigLoader _configLoader = ConfigLoader();

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);

  // Expose a method to apply remote config (e.g. Cloudflare env)
  void applyConfig(AppConfig config) {
    if (config != null) {
      _model = config.modelName.isNotEmpty ? config.modelName : _model;
      notifyListeners();
    }
  }

  bool isLoading = false;
  String? error;
  bool hasRiskWarning = false;
  bool isRecognizing = false;
  bool isSpeechPlaybackEnabled = true;

  bool get isSpeechSupported => _speechService.isSpeechSupported();
  bool get isTTSConfigured => _ttsClient.isConfigured;

  String _mapToUserSafeError(Object error) {
    final rawMessage = error.toString().toLowerCase();

    if (rawMessage.contains(' 400 ') || rawMessage.endsWith(' 400')) {
      return '请求内容无效，请修改后重试';
    }

    if (rawMessage.contains(' 404 ') ||
        rawMessage.endsWith(' 404') ||
        rawMessage.contains('not configured') ||
        rawMessage.contains('route missing') ||
        rawMessage.contains('service not configured')) {
      return 'AI 服务配置不可用，请稍后再试';
    }

    if (rawMessage.contains(' 502 ') ||
        rawMessage.endsWith(' 502') ||
        rawMessage.contains(' 503 ') ||
        rawMessage.endsWith(' 503') ||
        rawMessage.contains(' 504 ') ||
        rawMessage.endsWith(' 504') ||
        rawMessage.contains('upstream') ||
        rawMessage.contains('timeout')) {
      return 'AI 服务暂时不可用，请稍后再试';
    }

    return '发送失败，请稍后再试';
  }

  Future<void> _playAssistantSpeech(String text) async {
    if (!isSpeechPlaybackEnabled) {
      return;
    }

    if (_ttsClient.isConfigured && _audioPlaybackService.isSupported()) {
      try {
        final audioBytes = await _ttsClient.synthesize(text: text);
        await _audioPlaybackService.playBytes(audioBytes);
        return;
      } catch (_) {
        // Fall back to browser speech below.
      }
    }

    if (_speechService.isSpeechSupported()) {
      _speechService.speak(text);
    }
  }

  Future<void> sendText(String text) async {
    final content = text.trim();
    if (content.isEmpty || isLoading) {
      return;
    }

    _messages.add(
      ChatMessage(role: ChatRole.user, content: content, createdAt: DateTime.now()),
    );
    hasRiskWarning = ScamRules.containsRisk(content);
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Save user input to memory for context persistence
      _memory.add(text);
      await _memoryStore.save(_memory);
      final prompt = _promptBuilder.build(history: _messages, maxHistory: maxHistory);
      final reply = await _repository.sendMessage(model: model, messages: prompt);

      _messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: reply,
          createdAt: DateTime.now(),
        ),
      );
      // Persist AI reply to memory as part of conversation history
      _memory.add(reply);
      await _memoryStore.save(_memory);
      await _playAssistantSpeech(reply);
    } catch (e) {
      error = _mapToUserSafeError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startRecognition() {
    if (!isSpeechSupported) {
      isRecognizing = false;
      notifyListeners();
      return;
    }

    // Unlock browser audio autoplay policy on first interaction
    _speechService.unlockAudio();
    _speechService.startRecognition();
    isRecognizing = true;
    notifyListeners();
  }

  void stopRecognition() {
    _speechService.stopRecognition();
    isRecognizing = false;
    notifyListeners();
  }

  void toggleSpeechPlayback() {
    isSpeechPlaybackEnabled = !isSpeechPlaybackEnabled;
    notifyListeners();
  }

  Future<void> replayLastAssistantMessage() async {
    for (final message in _messages.reversed) {
      if (message.role == ChatRole.assistant) {
        await _playAssistantSpeech(message.content);
        return;
      }
    }
  }

  @visibleForTesting
  void debugAddAssistantMessage(String text) {
    _messages.add(
      ChatMessage(
        role: ChatRole.assistant,
        content: text,
        createdAt: DateTime.now(),
      ),
    );
  }
}
