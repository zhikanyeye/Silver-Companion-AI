import 'package:flutter/foundation.dart';
import 'package:yinling/services/web_speech_bridge.dart';

typedef BoolCallback = bool Function();
typedef StartRecognitionCallback = bool Function();
typedef VoidCallback0 = void Function();
typedef SpeakCallback = void Function(String text);

class WebSpeechService {
  WebSpeechService({
    BoolCallback? isWeb,
    BoolCallback? isRecognitionSupportedOnWeb,
    String Function()? recognitionUnsupportedReasonOnWeb,
    BoolCallback? isPlaybackSupportedOnWeb,
    StartRecognitionCallback? startRecognitionOnWeb,
    VoidCallback0? stopRecognitionOnWeb,
    SpeakCallback? speakOnWeb,
    VoidCallback0? unlockAudioOnWeb,
  }) : _isWeb = isWeb ?? (() => kIsWeb),
       _isRecognitionSupportedOnWeb =
           isRecognitionSupportedOnWeb ??
           speechRecognitionIsSupportedOnWebBridge,
       _recognitionUnsupportedReasonOnWeb =
           recognitionUnsupportedReasonOnWeb ??
           speechRecognitionUnsupportedReasonOnWebBridge,
       _isPlaybackSupportedOnWeb =
           isPlaybackSupportedOnWeb ?? speechPlaybackIsSupportedOnWebBridge,
       _startRecognitionOnWeb =
           startRecognitionOnWeb ?? speechStartRecognitionOnWebBridge,
       _stopRecognitionOnWeb =
           stopRecognitionOnWeb ?? speechStopRecognitionOnWebBridge,
       _speakOnWeb = speakOnWeb ?? speechSpeakTextOnWebBridge,
       _unlockAudioOnWeb = unlockAudioOnWeb ?? unlockAudioContextOnWebBridge;

  final BoolCallback _isWeb;
  final BoolCallback _isRecognitionSupportedOnWeb;
  final String Function() _recognitionUnsupportedReasonOnWeb;
  final BoolCallback _isPlaybackSupportedOnWeb;
  final StartRecognitionCallback _startRecognitionOnWeb;
  final VoidCallback0 _stopRecognitionOnWeb;
  final SpeakCallback _speakOnWeb;
  final VoidCallback0 _unlockAudioOnWeb;

  bool isRecognitionSupported() {
    if (!_isWeb()) {
      return false;
    }
    return _isRecognitionSupportedOnWeb();
  }

  String recognitionUnsupportedReason() {
    if (!_isWeb()) {
      return 'unsupported-platform';
    }
    return _recognitionUnsupportedReasonOnWeb();
  }

  bool isPlaybackSupported() {
    if (!_isWeb()) {
      return false;
    }
    return _isPlaybackSupportedOnWeb();
  }

  bool isSpeechSupported() => isRecognitionSupported() || isPlaybackSupported();

  void setRecognitionCallbacks({
    required void Function() onStart,
    required void Function(String) onInterim,
    required void Function(String) onFinal,
    required void Function(String) onError,
    required void Function() onEnd,
  }) {
    if (!_isWeb()) {
      return;
    }
    speechSetCallbacksOnWebBridge(
      onStart: onStart,
      onInterim: onInterim,
      onFinal: onFinal,
      onError: onError,
      onEnd: onEnd,
    );
  }

  bool startRecognition() {
    if (!_isWeb()) {
      return false;
    }
    return _startRecognitionOnWeb();
  }

  void stopRecognition() {
    if (!_isWeb()) {
      return;
    }
    _stopRecognitionOnWeb();
  }

  void speak(String text) {
    if (!_isWeb()) {
      return;
    }
    _speakOnWeb(text);
  }

  void unlockAudio() {
    if (!_isWeb()) {
      return;
    }
    _unlockAudioOnWeb();
  }
}
