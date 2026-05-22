// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

bool _callBool(String methodName, [List<dynamic> args = const <dynamic>[]]) {
  try {
    final result = js.context.callMethod(methodName, args);
    return result == true;
  } catch (_) {
    return false;
  }
}

bool speechRecognitionIsSupportedOnWebBridge() {
  return _callBool('speechRecognitionIsSupported');
}

String speechRecognitionUnsupportedReasonOnWebBridge() {
  try {
    final result = js.context.callMethod('speechRecognitionUnsupportedReason');
    return result?.toString() ?? 'unknown';
  } catch (_) {
    return 'unknown';
  }
}

bool speechPlaybackIsSupportedOnWebBridge() {
  return _callBool('speechPlaybackIsSupported');
}

bool speechStartRecognitionOnWebBridge() {
  return _callBool('speechStartRecognition');
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
  required void Function() onStart,
  required void Function(String) onInterim,
  required void Function(String) onFinal,
  required void Function(String) onError,
  required void Function() onEnd,
}) {
  try {
    js.context['onSpeechStart'] = js.JsFunction.withThis((_) {
      onStart();
    });
    js.context['onSpeechInterimResult'] = js.JsFunction.withThis((_, text) {
      onInterim(text?.toString() ?? '');
    });
    js.context['onSpeechFinalResult'] = js.JsFunction.withThis((_, text) {
      onFinal(text?.toString() ?? '');
    });
    js.context['onSpeechError'] = js.JsFunction.withThis((_, error) {
      onError(error?.toString() ?? '');
    });
    js.context['onSpeechEnd'] = js.JsFunction.withThis((_) {
      onEnd();
    });
  } catch (_) {}
}

void unlockAudioContextOnWebBridge() {
  try {
    js.context.callMethod('unlockAudioContext');
  } catch (_) {}
}
