import 'package:flutter/foundation.dart';

import 'package:yinling/config/app_config.dart';
import 'package:yinling/features/chat/chat_action_planner.dart';
import 'package:yinling/features/chat/chat_message.dart';
import 'package:yinling/features/chat/chat_publish_action.dart';
import 'package:yinling/features/chat/chat_repository.dart';
import 'package:yinling/features/chat/memory_store.dart';
import 'package:yinling/features/chat/prompt_builder.dart';
import 'package:yinling/features/chat/scam_rules.dart';
import 'package:yinling/features/community/community_feed_service.dart';
import 'package:yinling/features/elderly/elderly_activities_service.dart';
import 'package:yinling/services/audio_playback_service.dart';
import 'package:yinling/services/demo_identity_store.dart';
import 'package:yinling/services/kv_client.dart';
import 'package:yinling/services/tts_client.dart';
import 'package:yinling/services/web_speech_service.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    ChatRepository? repository,
    PromptBuilder? promptBuilder,
    WebSpeechService? speechService,
    TTSClient? ttsClient,
    AudioPlaybackService? audioPlaybackService,
    MemoryStore? memoryStore,
    ChatActionPlanner? actionPlanner,
    CommunityFeedService? communityFeedService,
    ElderlyActivitiesService? activitiesService,
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
       _actionPlanner =
           actionPlanner ?? AiChatActionPlanner(repository: repository),
       _communityFeedService = communityFeedService ?? CommunityFeedService(),
       _activitiesService = activitiesService ?? ElderlyActivitiesService(),
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
  final ChatActionPlanner _actionPlanner;
  final CommunityFeedService _communityFeedService;
  final ElderlyActivitiesService _activitiesService;
  final KvClient _kvClient;
  final DemoIdentityStore _identityStore;
  final int maxHistory;

  final List<ChatMessage> _messages = <ChatMessage>[];
  List<String> _memory = <String>[];
  String _model;
  ChatPublishIntent? _pendingPublishIntent;

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
  ChatPublishIntent? get pendingPublishIntent => _pendingPublishIntent;

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
        } else if (normalized == 'busy') {
          error = '上一段语音还在转写，请稍等一下再试。';
        } else if (normalized == 'insecure-context' ||
            normalized == 'unsupported-browser') {
          error = _mapSpeechSupportReasonToMessage(normalized);
        } else if (normalized == 'stt-unavailable') {
          error = '语音转写服务暂时不可用，请稍后再试或改用文字输入。';
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

  Future<void> _appendAssistantMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty) {
      return;
    }

    _messages.add(
      ChatMessage(
        role: ChatRole.assistant,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
    _memory.add(content);
    await _memoryStore.save(_memory);
    await _syncToKV();
    await _playAssistantSpeech(content);
  }

  void applyConfig(AppConfig config) {
    _model = config.modelName.isNotEmpty ? config.modelName : _model;
    notifyListeners();
  }

  String _mapSpeechSupportReasonToMessage(String reason) {
    switch (reason.trim().toLowerCase()) {
      case 'insecure-context':
        return '语音输入需要在 HTTPS 或 localhost 环境下使用，请检查当前访问地址。';
      case 'unsupported-browser':
        return '当前浏览器的语音识别支持不稳定，建议改用最新版 Chrome 或 Edge。';
      case 'unsupported-platform':
        return '当前运行环境暂不支持语音输入，请改用 Web 版浏览器。';
      default:
        return '当前浏览器暂不支持语音输入，请检查浏览器和麦克风权限。';
    }
  }

  String _mapSpeechStartFailureToMessage(String reason) {
    switch (reason.trim().toLowerCase()) {
      case 'insecure-context':
      case 'unsupported-browser':
        return _mapSpeechSupportReasonToMessage(reason);
      case 'unsupported-platform':
      default:
        return '语音输入启动失败，请检查麦克风权限后重试。';
    }
  }

  String _mapToUserSafeError(Object value) {
    final raw = value.toString().toLowerCase();

    if (raw.contains('community publish failed') ||
        raw.contains('activity publish failed')) {
      return '发布失败，请稍后重试。';
    }

    if (raw.contains(' 400 ') || raw.endsWith(' 400')) {
      return 'Request content is invalid. Please revise it and try again.';
    }

    if (raw.contains(' 401 ') ||
        raw.endsWith(' 401') ||
        raw.contains('401 status') ||
        raw.contains(' 403 ') ||
        raw.endsWith(' 403') ||
        raw.contains('403 status') ||
        raw.contains('unauthorized') ||
        raw.contains('forbidden') ||
        raw.contains('invalid api key') ||
        raw.contains('incorrect api key') ||
        raw.contains('authentication') ||
        raw.contains('permission')) {
      return 'AI service authentication failed. Please check the API key and model permissions.';
    }

    if (raw.contains(' 429 ') ||
        raw.endsWith(' 429') ||
        raw.contains('rate limit') ||
        raw.contains('quota') ||
        raw.contains('too many requests')) {
      return 'AI service is rate limited or out of quota. Please try again later.';
    }

    if (raw.contains(' 404 ') ||
        raw.endsWith(' 404') ||
        raw.contains(' 405 ') ||
        raw.endsWith(' 405') ||
        raw.contains('"errortype":"configuration"') ||
        raw.contains("'errortype': 'configuration'") ||
        raw.contains('not configured') ||
        raw.contains('route missing') ||
        raw.contains('service not configured') ||
        raw.contains('invalid json shape')) {
      return 'AI service configuration is unavailable. Please try again later.';
    }

    if (raw.contains(' 502 ') ||
        raw.endsWith(' 502') ||
        raw.contains(' 503 ') ||
        raw.endsWith(' 503') ||
        raw.contains(' 504 ') ||
        raw.endsWith(' 504') ||
        raw.contains('"errortype":"upstream_error"') ||
        raw.contains('"errortype":"upstream_unreachable"') ||
        raw.contains('upstream') ||
        raw.contains('timeout') ||
        raw.contains('failed to fetch') ||
        raw.contains('xmlhttprequest') ||
        raw.contains('clientexception') ||
        raw.contains('network')) {
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

  bool _looksLikePublishIntent(String content) {
    final normalized = content.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }

    final publishHints = <String>[
      '发布',
      '发个',
      '发一条',
      '帮我发',
      '替我发',
      '代我发',
      '创建',
      '建个',
      '建一个',
      '组织',
      '办个',
      '想发',
      '想发布',
    ];
    final communityHints = <String>['互助', '求助', '邻里', '社区', '帮忙'];
    final activityHints = <String>['活动', '茶话会', '讲座', '义诊', '课程', '联谊'];

    final hasPublishHint = publishHints.any(normalized.contains);
    final hasCommunityHint = communityHints.any(normalized.contains);
    final hasActivityHint = activityHints.any(normalized.contains);

    return (hasPublishHint && (hasCommunityHint || hasActivityHint)) ||
        (hasActivityHint &&
            (normalized.contains('办') ||
                normalized.contains('建') ||
                normalized.contains('组织'))) ||
        (hasCommunityHint &&
            (normalized.contains('发') ||
                normalized.contains('发布') ||
                normalized.contains('求助')));
  }

  bool _isPublishConfirmation(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), '');
    const confirmPhrases = <String>{
      '确认',
      '确认发布',
      '发布',
      '发布吧',
      '就这样发布',
      '帮我发布',
      '确定发布',
      '可以发布',
      '好，发布',
      '好的，发布',
    };
    return confirmPhrases.contains(normalized);
  }

  bool _isPublishCancellation(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), '');
    const cancelPhrases = <String>{
      '取消',
      '取消发布',
      '先不发布',
      '不用发布了',
      '算了',
      '撤销',
      '不要发布',
    };
    return cancelPhrases.contains(normalized);
  }

  String _fallbackPublishReply(ChatPublishIntent intent) {
    if (intent.isReadyForConfirmation) {
      return switch (intent.target) {
        ChatPublishTarget.community => '我已经整理好这条互助信息，确认后就帮您发布。',
        ChatPublishTarget.activity => '我已经整理好这场社区活动，确认后就帮您发布。',
        null => '',
      };
    }

    if (intent.missingFields.isEmpty) {
      return '我先帮您整理发布内容，您也可以继续补充细节。';
    }

    return '我还差一点信息，您补充后我就能继续整理发布草稿。';
  }

  Future<bool> _maybeHandlePublishFlow(String content) async {
    if (_pendingPublishIntent == null && !_looksLikePublishIntent(content)) {
      return false;
    }

    try {
      final identity = await _identityStore.loadOrCreate();
      final intent = await _actionPlanner.analyze(
        history: messages,
        identity: identity,
        model: model,
        pendingIntent: _pendingPublishIntent,
      );

      if (!intent.isPublishIntent) {
        return false;
      }

      _pendingPublishIntent = intent;
      await _appendAssistantMessage(
        intent.reply.isNotEmpty ? intent.reply : _fallbackPublishReply(intent),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _confirmPendingPublishInternal() async {
    final pending = _pendingPublishIntent;
    if (pending == null || !pending.isReadyForConfirmation) {
      return;
    }

    final identity = await _identityStore.loadOrCreate();

    switch (pending.target) {
      case ChatPublishTarget.community:
        final draft = pending.communityDraft?.withDefaults(identity);
        if (draft == null) {
          return;
        }
        final created = await _communityFeedService.publishPost(
          username: draft.username,
          identity: draft.identity,
          tag: draft.tag,
          title: draft.title,
          location: draft.location,
          summary: draft.summary,
        );
        _pendingPublishIntent = null;
        await _appendAssistantMessage(
          '已帮您发布社区互助“${created.title}”，您可以去社区页面查看。',
        );
        return;
      case ChatPublishTarget.activity:
        final draft = pending.activityDraft?.withDefaults(identity);
        if (draft == null) {
          return;
        }
        final created = await _activitiesService.publishActivity(
          organizerName: draft.organizerName,
          title: draft.title,
          location: draft.location,
          description: draft.description,
          tag: draft.tag,
          time: draft.time,
          group: draft.group,
        );
        _pendingPublishIntent = null;
        await _appendAssistantMessage(
          '已帮您创建社区活动“${created.title}”，您可以去活动页面查看。',
        );
        return;
      case null:
        return;
    }
  }

  Future<void> _cancelPendingPublishInternal() async {
    if (_pendingPublishIntent == null) {
      return;
    }

    _pendingPublishIntent = null;
    await _appendAssistantMessage('好的，这次发布草稿已经取消。');
  }

  Future<void> confirmPendingPublish() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _confirmPendingPublishInternal();
    } catch (_) {
      error = '发布失败，请稍后重试。';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelPendingPublish() async {
    if (isLoading) {
      return;
    }

    await _cancelPendingPublishInternal();
    notifyListeners();
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

      if (_pendingPublishIntent != null && _isPublishConfirmation(content)) {
        await _confirmPendingPublishInternal();
        return;
      }

      if (_pendingPublishIntent != null && _isPublishCancellation(content)) {
        await _cancelPendingPublishInternal();
        return;
      }

      if (await _maybeHandlePublishFlow(content)) {
        return;
      }

      final prompt = _promptBuilder.build(
        history: _messages,
        maxHistory: maxHistory,
      );
      final reply = await _repository.sendMessage(
        model: model,
        messages: prompt,
      );

      await _appendAssistantMessage(reply);
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
      error = _mapSpeechSupportReasonToMessage(
        _speechService.recognitionUnsupportedReason(),
      );
      notifyListeners();
      return;
    }

    _speechService.unlockAudio();
    final started = _speechService.startRecognition();
    isRecognizing = started;
    if (!started) {
      error ??= _mapSpeechStartFailureToMessage(
        _speechService.recognitionUnsupportedReason(),
      );
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
    _pendingPublishIntent = null;
    await _memoryStore.save(<String>[]);
    await _kvClient.delete(await _historyKey());

    error = null;
    hasRiskWarning = false;
    notifyListeners();
  }
}
