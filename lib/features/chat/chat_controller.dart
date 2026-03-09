import 'package:flutter/foundation.dart';

import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_repository.dart';
import 'package:yinling_zhiban_demo/features/chat/prompt_builder.dart';
import 'package:yinling_zhiban_demo/features/chat/scam_rules.dart';
import 'package:yinling_zhiban_demo/services/web_speech_service.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    ChatRepository? repository,
    PromptBuilder? promptBuilder,
    WebSpeechService? speechService,
    this.model = 'openai/gpt-4o-mini',
    this.maxHistory = 12,
  })  : _repository = repository ?? ChatRepository(),
        _promptBuilder = promptBuilder ?? const PromptBuilder(),
        _speechService = speechService ?? WebSpeechService();

  final ChatRepository _repository;
  final PromptBuilder _promptBuilder;
  final WebSpeechService _speechService;
  final String model;
  final int maxHistory;

  final List<ChatMessage> _messages = <ChatMessage>[];

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);

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
      final prompt = _promptBuilder.build(history: _messages, maxHistory: maxHistory);
      final reply = await _repository.sendMessage(model: model, messages: prompt);

      _messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: reply,
          createdAt: DateTime.now(),
        ),
      );
      _speechService.speak(reply);
    } catch (e) {
      error = '发送失败，请稍后再试';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startRecognition() {
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
