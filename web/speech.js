let speechRecognitionInstance = null;

function resolveSpeechRecognitionCtor() {
  if (typeof window === 'undefined') {
    return null;
  }

  return window.SpeechRecognition || window.webkitSpeechRecognition || null;
}

window.speechIsSupported = function speechIsSupported() {
  const hasRecognition = resolveSpeechRecognitionCtor() !== null;
  const hasSynthesis =
    typeof window !== 'undefined' &&
    typeof window.speechSynthesis !== 'undefined' &&
    typeof window.SpeechSynthesisUtterance !== 'undefined';

  return hasRecognition || hasSynthesis;
};

window.speechStartRecognition = function speechStartRecognition() {
  const SpeechRecognitionCtor = resolveSpeechRecognitionCtor();
  if (SpeechRecognitionCtor === null) {
    return;
  }

  if (speechRecognitionInstance === null) {
    speechRecognitionInstance = new SpeechRecognitionCtor();
    speechRecognitionInstance.continuous = true;
    speechRecognitionInstance.interimResults = true;
  }

  try {
    speechRecognitionInstance.start();
  } catch (_) {
    return;
  }
};

window.speechStopRecognition = function speechStopRecognition() {
  if (speechRecognitionInstance === null) {
    return;
  }

  try {
    speechRecognitionInstance.stop();
  } catch (_) {
    return;
  }
};

window.speechSpeakText = function speechSpeakText(text) {
  if (
    typeof window === 'undefined' ||
    typeof window.speechSynthesis === 'undefined' ||
    typeof window.SpeechSynthesisUtterance === 'undefined'
  ) {
    return;
  }

  const value = typeof text === 'string' ? text : String(text ?? '');
  if (value.length === 0) {
    return;
  }

  try {
    const utterance = new window.SpeechSynthesisUtterance(value);
    window.speechSynthesis.speak(utterance);
  } catch (_) {
    return;
  }
};
