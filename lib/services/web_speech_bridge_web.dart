import 'package:js/js.dart';

@JS('speechIsSupported')
external bool _speechIsSupportedJs();

@JS('speechStartRecognition')
external void _speechStartRecognitionJs();

@JS('speechStopRecognition')
external void _speechStopRecognitionJs();

@JS('speechSpeakText')
external void _speechSpeakTextJs(String text);

bool speechIsSupportedOnWebBridge() {
  try {
    return _speechIsSupportedJs();
  } catch (_) {
    return false;
  }
}

void speechStartRecognitionOnWebBridge() {
  try {
    _speechStartRecognitionJs();
  } catch (_) {
    return;
  }
}

void speechStopRecognitionOnWebBridge() {
  try {
    _speechStopRecognitionJs();
  } catch (_) {
    return;
  }
}

void speechSpeakTextOnWebBridge(String text) {
  try {
    _speechSpeakTextJs(text);
  } catch (_) {
    return;
  }
}
