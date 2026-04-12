import 'package:flutter/foundation.dart';

import 'package:yinling_zhiban_demo/config/app_config.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_repository.dart';
import 'package:yinling_zhiban_demo/features/chat/memory_store.dart';
import 'package:yinling_zhiban_demo/features/chat/prompt_builder.dart';
import 'package:yinling_zhiban_demo/features/chat/scam_rules.dart';
import 'package:yinling_zhiban_demo/services/audio_playback_service.dart';
import 'package:yinling_zhiban_demo/services/demo_identity_store.dart';
import 'package:yinling_zhiban_demo/services/kv_client.dart';
import 'package:yinling_zhiban_demo/services/tts_client.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    ChatRepository? repository,
    PromptBuilder? promptBuilder,
    WebSpeechService? speechService,
    TTSClient? ttsClient,
    AudioPlaybackService? audioPlaybackService,
    MemoryStore? memoryStore,
    String? model,
    KvClient? kvClient,
    DemoIdentityStore? identityStore,
    this.maxHistory = 12,
  }) : _repository = repository ?? ChatRepository(),
       _promptBuilder = promptBuilder ?? const PromptBuilder(),
       _speechService = speechService ?? WebSpeechService(),
       _ttsClient = ttsClient ?? TTSClient(),
       _audioPlaybackService = audioPlaybackService ?? AudioPlaybackService(),
       _memoryStore = memoryStore ?? MemoryStore(),
       _kvClient = kvClient ?? const KvClient(),
       _identityStore = identityStore ?? DemoIdentityStore(),
       _model = model ?? 'openai/gpt-4o-mini' {
    _bindSpeechCallbacks();
    _loadMemory();
  }

  final ChatRepository _repository;
  final PromptBuilder _promptBuilder;
  final WebSpeechService _speechService;
  final TTSClient _ttsClient;
  final AudioPlaybackService _audioPlaybackService;
  final MemoryStore _memoryStore;
  final KvClient _kvClient;
  final DemoIdentityStore _identityStore;
  final int maxHistory;

  final List<ChatMessage> _messages = <ChatMessage>[];
  List<String> _memory = <String>[];
  String _model;

  void Function(String text)? onInterimText;
  void Function(String text)? onFinalText;

  bool isLoading = false;
  String? error;
  bool hasRiskWarning = false;
  bool isRecognizing = false;
  bool isSpeechPlaybackEnabled = true;

  String get model => _model;
  bool get isSpeechSupported => _speechService.isSpeechSupported();
  bool get isSpeechInputSupported => _speechService.isRecognitionSupported();
  bool get isSpeechOutputSupported =>
      _speechService.isPlaybackSupported() ||
      (_ttsClient.isConfigured && _audioPlaybackService.isSupported());
  bool get isTTSConfigured => _ttsClient.isConfigured;
  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);

  Future<String> _historyKey() async {
    final identity = await _identityStore.loadOrCreate();
    return 'chat_history_${identity.actorId}';
  }

  Future<void> _loadMemory() async {
    _memory = await _memoryStore.load();

    final kvData = await _kvClient.get(await _historyKey());
    if (kvData != null && kvData['messages'] is List) {
      final entries = kvData['messages'] as List;
      _messages
        ..clear()
        ..addAll(
          entries.map(
            (entry) => ChatMessage.fromJson(entry as Map<String, dynamic>),
          ),
        );
    }

    notifyListeners();
  }

  void _bindSpeechCallbacks() {
    _speechService.setRecognitionCallbacks(
      onStart: () {
        if (!isRecognizing) {
          isRecognizing = true;
          error = null;
          notifyListeners();
        }
      },
      onInterim: (text) => onInterimText?.call(text),
      onFinal: (text) => onFinalText?.call(text),
      onError: (message) {
        final normalized = message.trim().toLowerCase();
        if (normalized.isEmpty || normalized == 'no-speech') {
          error = '没有识别到语音，请靠近麦克风后再试一次。';
        } else if (normalized == 'not-allowed' ||
            normalized == 'service-not-allowed') {
          error = '麦克风权限被拒绝，请在浏览器中允许麦克风访问后重试。';
        } else if (normalized == 'audio-capture') {
          error = '未检测到可用麦克风，请检查设备后重试。';
        } else if (normalized == 'network') {
          error = '语音识别网络异常，请稍后再试。';
        } else if (normalized == 'aborted') {
          error = null;
        } else {
          error = '语音输入中断，请稍后重试。';
        }
        notifyListeners();
      },
      onEnd: () {
        if (isRecognizing) {
          isRecognizing = false;
          notifyListeners();
        }
      },
    );
  }

  Future<void> _syncToKV() async {
    await _kvClient.put(await _historyKey(), <String, dynamic>{
      'messages': _messages.map((message) => message.toJson()).toList(),
    });
  }

  void applyConfig(AppConfig config) {
    _model = config.modelName.isNotEmpty ? config.modelName : _model;
    notifyListeners();
  }

  String _mapToUserSafeError(Object value) {
    final raw = value.toString().toLowerCase();

    if (raw.contains(' 400 ') || raw.endsWith(' 400')) {
      return 'Request content is invalid. Please revise it and try again.';
    }

    if (raw.contains(' 404 ') ||
        raw.endsWith(' 404') ||
        raw.contains('not configured') ||
        raw.contains('route missing') ||
        raw.contains('service not configured')) {
      return 'AI service configuration is unavailable. Please try again later.';
    }

    if (raw.contains(' 502 ') ||
        raw.endsWith(' 502') ||
        raw.contains(' 503 ') ||
        raw.endsWith(' 503') ||
        raw.contains(' 504 ') ||
        raw.endsWith(' 504') ||
        raw.contains('upstream') ||
        raw.contains('timeout')) {
      return 'AI service is temporarily unavailable. Please try again later.';
    }

    return 'Message failed to send. Please try again later.';
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

    if (_speechService.isPlaybackSupported()) {
      _speechService.speak(text);
    }
  }

  Future<void> sendText(String text) async {
    final content = text.trim();
    if (content.isEmpty || isLoading) {
      return;
    }

    _messages.add(
      ChatMessage(
        role: ChatRole.user,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
    hasRiskWarning = ScamRules.containsRisk(content);
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _memory.add(content);
      await _memoryStore.save(_memory);

      final prompt = _promptBuilder.build(
        history: _messages,
        maxHistory: maxHistory,
      );
      final reply = await _repository.sendMessage(
        model: model,
        messages: prompt,
      );

      _messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: reply,
          createdAt: DateTime.now(),
        ),
      );
      _memory.add(reply);
      await _memoryStore.save(_memory);

      _syncToKV();
      await _playAssistantSpeech(reply);
    } catch (value) {
      error = _mapToUserSafeError(value);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startRecognition() {
    if (!isSpeechInputSupported) {
      isRecognizing = false;
      error = '当前浏览器暂不支持语音输入，请检查浏览器和麦克风权限。';
      notifyListeners();
      return;
    }

    _speechService.unlockAudio();
    final started = _speechService.startRecognition();
    isRecognizing = started;
    if (!started) {
      error = '语音输入启动失败，请检查麦克风权限后重试。';
    } else {
      error = null;
    }
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

  Future<void> clearMessages() async {
    _messages.clear();
    _memory.clear();
    await _memoryStore.save(<String>[]);
    await _kvClient.delete(await _historyKey());

    error = null;
    hasRiskWarning = false;
    notifyListeners();
  }
}
