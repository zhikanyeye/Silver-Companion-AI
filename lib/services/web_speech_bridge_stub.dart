bool speechRecognitionIsSupportedOnWebBridge() => false;

bool speechPlaybackIsSupportedOnWebBridge() => false;

bool speechStartRecognitionOnWebBridge() => false;

void speechStopRecognitionOnWebBridge() {}

void speechSpeakTextOnWebBridge(String text) {}

void speechSetCallbacksOnWebBridge({
  required void Function(String) onInterim,
  required void Function(String) onFinal,
  required void Function() onEnd,
}) {}

void unlockAudioContextOnWebBridge() {}
