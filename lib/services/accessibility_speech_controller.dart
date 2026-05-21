import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:yinling/services/audio_playback_service.dart';
import 'package:yinling/services/tts_client.dart';
import 'package:yinling/services/web_speech_service.dart';

class AccessibilitySpeechController extends ChangeNotifier {
  AccessibilitySpeechController({
    TTSClient? ttsClient,
    AudioPlaybackService? audioPlaybackService,
    WebSpeechService? webSpeechService,
  }) : _ttsClient = ttsClient ?? TTSClient(),
       _audioPlaybackService = audioPlaybackService ?? AudioPlaybackService(),
       _webSpeechService = webSpeechService ?? WebSpeechService();

  final TTSClient _ttsClient;
  final AudioPlaybackService _audioPlaybackService;
  final WebSpeechService _webSpeechService;

  bool _enabled = false;
  bool _isSpeaking = false;
  String? _lastText;
  DateTime? _lastSpokenAt;

  bool get enabled => _enabled;
  bool get isSpeaking => _isSpeaking;

  void toggle() {
    _enabled = !_enabled;
    notifyListeners();
  }

  Future<void> speakFromContext(BuildContext context) async {
    if (!_enabled) {
      return;
    }

    final text = _extractReadableText(context);
    if (text == null || text.isEmpty) {
      return;
    }

    await speak(text);
  }

  Future<void> speakFromElement(Element element) async {
    if (!_enabled) {
      return;
    }

    final text = extractReadableTextFromElement(element);
    if (text == null || text.isEmpty) {
      return;
    }

    await speak(text);
  }

  Future<void> speak(String text) async {
    final readable = _normalizeText(text);
    if (readable.isEmpty || _shouldSkip(readable)) {
      return;
    }

    _lastText = readable;
    _lastSpokenAt = DateTime.now();
    _isSpeaking = true;
    notifyListeners();

    try {
      if (_audioPlaybackService.isSupported()) {
        final bytes = await _ttsClient.synthesize(text: readable, speed: 0.95);
        await _audioPlaybackService.playBytes(bytes, mimeType: 'audio/mpeg');
        return;
      }

      if (_webSpeechService.isPlaybackSupported()) {
        _webSpeechService.speak(readable);
      }
    } catch (_) {
      if (_webSpeechService.isPlaybackSupported()) {
        _webSpeechService.speak(readable);
      }
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  bool _shouldSkip(String text) {
    final lastSpokenAt = _lastSpokenAt;
    if (_lastText != text || lastSpokenAt == null) {
      return false;
    }
    return DateTime.now().difference(lastSpokenAt) <
        const Duration(milliseconds: 900);
  }

  @visibleForTesting
  String? extractReadableTextFromElement(Element element) {
    final labels = <String>[];
    _collectReadableLabels(element, labels, depth: 0);

    final merged = labels
        .map(_normalizeText)
        .where((value) => value.isNotEmpty)
        .toSet()
        .take(4)
        .join('。');

    return merged.isEmpty ? null : merged;
  }

  String? _extractReadableText(BuildContext context) {
    final labels = <String>[];
    context.visitChildElements((element) {
      _collectReadableLabels(element, labels, depth: 0);
    });

    final merged = labels
        .map(_normalizeText)
        .where((value) => value.isNotEmpty)
        .toSet()
        .take(4)
        .join('。');

    return merged.isEmpty ? null : merged;
  }

  void _collectReadableLabels(
    Element element,
    List<String> labels, {
    required int depth,
  }) {
    if (depth > 6 || labels.length >= 6) {
      return;
    }

    final widget = element.widget;
    switch (widget) {
      case Text(:final data):
        if (data != null) {
          labels.add(data);
        }
      case SelectableText(:final data):
        labels.add(data);
      case RichText(:final text):
        labels.add(text.toPlainText());
      case Semantics(:final properties):
        final label = properties.label;
        if (label != null && label.isNotEmpty) {
          labels.add(label);
        }
      case Tooltip(:final message):
        labels.add(message);
      case IconButton(:final tooltip):
        if (tooltip != null) {
          labels.add(tooltip);
        }
      default:
        break;
    }

    element.visitChildElements((child) {
      _collectReadableLabels(child, labels, depth: depth + 1);
    });
  }

  String _normalizeText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .trim();
  }
}
