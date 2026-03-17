import 'package:flutter/foundation.dart';

import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_repository.dart';
import 'package:yinling_zhiban_demo/features/chat/prompt_builder.dart';
import 'package:yinling_zhiban_demo/features/chat/scam_rules.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';
import 'package:yinling_zhiban_demo/config/app_config.dart';
import 'package:yinling_zhiban_demo/config/config_loader.dart';
import 'package:yinling_zhiban_demo/features/chat/memory_store.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    ChatRepository? repository,
    PromptBuilder? promptBuilder,
    WebSpeechService? speechService,
    MemoryStore? memoryStore,
    String? model,
    this.maxHistory = 12,
  })  : _repository = repository ?? ChatRepository(),
        _promptBuilder = promptBuilder ?? const PromptBuilder(),
        _speechService = speechService ?? WebSpeechService(),
        _memoryStore = memoryStore ?? MemoryStore(),
        _model = model ?? 'openai/gpt-4o-mini' {
  // Initialize memory asynchronously (best-effort)
  _loadMemory();
}

  final ChatRepository _repository;
  final PromptBuilder _promptBuilder;
  final WebSpeechService _speechService;
  String _model;
  String get model => _model;
  final int maxHistory;

  final List<ChatMessage> _messages = <ChatMessage>[];
  final MemoryStore _memoryStore;
  List<String> _memory = [];

  Future<void> _loadMemory() async {
    _memory = await _memoryStore.load();
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

  bool get isSpeechSupported => _speechService.isSpeechSupported();

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
      _speechService.speak(reply);
    } catch (e) {
      error = '发送失败，请稍后再试';
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

    _speechService.startRecognition();
    isRecognizing = true;
    notifyListeners();
  }

  void stopRecognition() {
    _speechService.stopRecognition();
    isRecognizing = false;
    notifyListeners();
  }
}
