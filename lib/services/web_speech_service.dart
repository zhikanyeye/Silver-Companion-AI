import 'package:flutter/foundation.dart';
import 'package:yinling_zhiban_demo/services/web_speech_bridge.dart';

typedef BoolCallback = bool Function();
typedef VoidCallback0 = void Function();
typedef SpeakCallback = void Function(String text);

class WebSpeechService {
  WebSpeechService({
    BoolCallback? isWeb,
    BoolCallback? isSpeechSupportedOnWeb,
    VoidCallback0? startRecognitionOnWeb,
    VoidCallback0? stopRecognitionOnWeb,
    SpeakCallback? speakOnWeb,
    VoidCallback0? unlockAudioOnWeb,
  })  : _isWeb = isWeb ?? (() => kIsWeb),
        _isSpeechSupportedOnWeb = isSpeechSupportedOnWeb ?? speechIsSupportedOnWebBridge,
        _startRecognitionOnWeb = startRecognitionOnWeb ?? speechStartRecognitionOnWebBridge,
        _stopRecognitionOnWeb = stopRecognitionOnWeb ?? speechStopRecognitionOnWebBridge,
        _speakOnWeb = speakOnWeb ?? speechSpeakTextOnWebBridge,
        _unlockAudioOnWeb = unlockAudioOnWeb ?? unlockAudioContextOnWebBridge;

  final BoolCallback _isWeb;
  final BoolCallback _isSpeechSupportedOnWeb;
  final VoidCallback0 _startRecognitionOnWeb;
  final VoidCallback0 _stopRecognitionOnWeb;
  final SpeakCallback _speakOnWeb;
  final VoidCallback0 _unlockAudioOnWeb;

  bool isSpeechSupported() {
    if (!_isWeb()) return false;
    return _isSpeechSupportedOnWeb();
  }

  void setRecognitionCallbacks({
    required void Function(String) onInterim,
    required void Function(String) onFinal,
    required void Function() onEnd,
  }) {
    if (!_isWeb()) return;
    speechSetCallbacksOnWebBridge(
      onInterim: onInterim,
      onFinal: onFinal,
      onEnd: onEnd,
    );
  }

  void startRecognition() {
    if (!_isWeb()) return;
    _startRecognitionOnWeb();
  }

  void stopRecognition() {
    if (!_isWeb()) return;
    _stopRecognitionOnWeb();
  }

  void speak(String text) {
    if (!_isWeb()) return;
    _speakOnWeb(text);
  }

  void unlockAudio() {
    if (!_isWeb()) return;
    _unlockAudioOnWeb();
  }
}
