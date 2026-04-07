let speechRecognitionInstance = null;
let pendingRecognitionText = '';
let emittedFinalText = false;

function resolveSpeechRecognitionCtor() {
  if (typeof window === 'undefined') return null;
  return window.SpeechRecognition || window.webkitSpeechRecognition || null;
}

window.speechIsSupported = function() {
  return (
    window.speechRecognitionIsSupported() ||
    window.speechPlaybackIsSupported()
  );
};

window.speechRecognitionIsSupported = function() {
  return resolveSpeechRecognitionCtor() !== null;
};

window.speechPlaybackIsSupported = function() {
  return (
    typeof window !== 'undefined' &&
    typeof window.speechSynthesis !== 'undefined' &&
    typeof window.SpeechSynthesisUtterance !== 'undefined'
  );
};

window.speechStartRecognition = function() {
  const SpeechRecognitionCtor = resolveSpeechRecognitionCtor();
  if (SpeechRecognitionCtor === null) return false;

  // Re-create instance each time to avoid stale state
  if (speechRecognitionInstance !== null) {
    try {
      speechRecognitionInstance.abort();
    } catch (_) {}
  }
  speechRecognitionInstance = new SpeechRecognitionCtor();
  pendingRecognitionText = '';
  emittedFinalText = false;
  speechRecognitionInstance.continuous = false;
  speechRecognitionInstance.interimResults = true;
  speechRecognitionInstance.lang = 'zh-CN';

  speechRecognitionInstance.onresult = function(event) {
    let interim = '';
    let final = '';
    for (let i = event.resultIndex; i < event.results.length; i++) {
      const t = event.results[i][0].transcript;
      if (event.results[i].isFinal) {
        final += t;
      } else {
        interim += t;
      }
    }
    const latestText = (final || interim).trim();
    if (latestText) {
      pendingRecognitionText = latestText;
    }
    if (interim && typeof window.onSpeechInterimResult === 'function') {
      window.onSpeechInterimResult(interim);
    }
    if (final && typeof window.onSpeechFinalResult === 'function') {
      emittedFinalText = true;
      window.onSpeechFinalResult(final);
    }
  };

  speechRecognitionInstance.onend = function() {
    if (
      !emittedFinalText &&
      pendingRecognitionText &&
      typeof window.onSpeechFinalResult === 'function'
    ) {
      window.onSpeechFinalResult(pendingRecognitionText);
    }
    pendingRecognitionText = '';
    emittedFinalText = false;
    if (typeof window.onSpeechEnd === 'function') window.onSpeechEnd();
  };

  speechRecognitionInstance.onerror = function() {
    if (
      !emittedFinalText &&
      pendingRecognitionText &&
      typeof window.onSpeechFinalResult === 'function'
    ) {
      window.onSpeechFinalResult(pendingRecognitionText);
    }
    pendingRecognitionText = '';
    emittedFinalText = false;
    if (typeof window.onSpeechEnd === 'function') window.onSpeechEnd();
  };

  try {
    speechRecognitionInstance.start();
    return true;
  } catch (_) {
    return false;
  }
};

window.speechStopRecognition = function() {
  if (speechRecognitionInstance === null) return;
  try {
    speechRecognitionInstance.stop();
  } catch (_) {}
};

window.speechSpeakText = function(text) {
  if (
    typeof window === 'undefined' ||
    typeof window.speechSynthesis === 'undefined' ||
    typeof window.SpeechSynthesisUtterance === 'undefined'
  ) return;

  const value = typeof text === 'string' ? text : String(text ?? '');
  if (value.length === 0) return;

  try {
    window.speechSynthesis.cancel();
    const utterance = new window.SpeechSynthesisUtterance(value);
    utterance.lang = 'zh-CN';
    utterance.rate = 0.9;
    window.speechSynthesis.speak(utterance);
  } catch (_) {}
};

// Called from Dart on first user interaction to unlock browser audio autoplay policy
window.unlockAudioContext = function() {
  try {
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    const ctx = new AudioCtx();
    const buffer = ctx.createBuffer(1, 1, 22050);
    const source = ctx.createBufferSource();
    source.buffer = buffer;
    source.connect(ctx.destination);
    source.start(0);
    setTimeout(() => ctx.close(), 500);
  } catch (_) {}
};
