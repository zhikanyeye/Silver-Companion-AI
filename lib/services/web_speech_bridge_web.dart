// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

bool speechIsSupportedOnWebBridge() {
  try {
    final result = js.context.callMethod('speechIsSupported');
    return result == true;
  } catch (_) {
    return false;
  }
}

void speechStartRecognitionOnWebBridge() {
  try {
    js.context.callMethod('speechStartRecognition');
  } catch (_) {}
}

void speechStopRecognitionOnWebBridge() {
  try {
    js.context.callMethod('speechStopRecognition');
  } catch (_) {}
}

void speechSpeakTextOnWebBridge(String text) {
  try {
    js.context.callMethod('speechSpeakText', [text]);
  } catch (_) {}
}

void speechSetCallbacksOnWebBridge({
  required void Function(String) onInterim,
  required void Function(String) onFinal,
  required void Function() onEnd,
}) {
  try {
    js.context['onSpeechInterimResult'] = (dynamic text) {
      onInterim(text?.toString() ?? '');
    };
    js.context['onSpeechFinalResult'] = (dynamic text) {
      onFinal(text?.toString() ?? '');
    };
    js.context['onSpeechEnd'] = () {
      onEnd();
    };
  } catch (_) {}
}

void unlockAudioContextOnWebBridge() {
  try {
    js.context.callMethod('unlockAudioContext');
  } catch (_) {}
}
