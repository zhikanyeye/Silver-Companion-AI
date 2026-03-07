import 'package:flutter/foundation.dart';

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
  })  : _isWeb = isWeb ?? (() => kIsWeb),
        _isSpeechSupportedOnWeb = isSpeechSupportedOnWeb ?? (() => false),
        _startRecognitionOnWeb = startRecognitionOnWeb ?? (() {}),
        _stopRecognitionOnWeb = stopRecognitionOnWeb ?? (() {}),
        _speakOnWeb = speakOnWeb ?? ((_) {});

  final BoolCallback _isWeb;
  final BoolCallback _isSpeechSupportedOnWeb;
  final VoidCallback0 _startRecognitionOnWeb;
  final VoidCallback0 _stopRecognitionOnWeb;
  final SpeakCallback _speakOnWeb;

  bool isSpeechSupported() {
    if (!_isWeb()) {
      return false;
    }

    return _isSpeechSupportedOnWeb();
  }

  void startRecognition() {
    if (!_isWeb()) {
      return;
    }

    _startRecognitionOnWeb();
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
}
