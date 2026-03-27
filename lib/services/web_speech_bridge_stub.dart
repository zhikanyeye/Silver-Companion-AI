bool speechIsSupportedOnWebBridge() => false;

void speechStartRecognitionOnWebBridge() {}

void speechStopRecognitionOnWebBridge() {}

void speechSpeakTextOnWebBridge(String text) {}

void speechSetCallbacksOnWebBridge({
  required void Function(String) onInterim,
  required void Function(String) onFinal,
  required void Function() onEnd,
}) {}

void unlockAudioContextOnWebBridge() {}
