let speechRecognitionInstance = null;
let pendingRecognitionText = '';
let emittedFinalText = false;
let activeRecognitionToken = 0;

function resolveSpeechRecognitionCtor() {
  if (typeof window === 'undefined') return null;
  return window.SpeechRecognition || window.webkitSpeechRecognition || null;
}

function emitFinalIfNeeded() {
  if (
    !emittedFinalText &&
    pendingRecognitionText &&
    typeof window.onSpeechFinalResult === 'function'
  ) {
    emittedFinalText = true;
    window.onSpeechFinalResult(pendingRecognitionText);
  }
}

function finishRecognition(token) {
  if (token !== activeRecognitionToken) {
    return;
  }

  emitFinalIfNeeded();
  pendingRecognitionText = '';
  emittedFinalText = false;
  speechRecognitionInstance = null;

  if (typeof window.onSpeechEnd === 'function') {
    window.onSpeechEnd();
  }
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

  activeRecognitionToken += 1;
  const token = activeRecognitionToken;

  if (speechRecognitionInstance !== null) {
    try {
      speechRecognitionInstance.abort();
    } catch (_) {}
  }

  const recognition = new SpeechRecognitionCtor();
  speechRecognitionInstance = recognition;
  pendingRecognitionText = '';
  emittedFinalText = false;

  recognition.continuous = false;
  recognition.interimResults = true;
  recognition.maxAlternatives = 1;
  recognition.lang = 'zh-CN';

  recognition.onstart = function() {
    if (token !== activeRecognitionToken) {
      return;
    }
    if (typeof window.onSpeechStart === 'function') {
      window.onSpeechStart();
    }
  };

  recognition.onresult = function(event) {
    if (token !== activeRecognitionToken) {
      return;
    }

    let interim = '';
    let finalText = '';

    for (let i = event.resultIndex; i < event.results.length; i += 1) {
      const transcript = (event.results[i][0].transcript || '').trim();
      if (!transcript) {
        continue;
      }

      if (event.results[i].isFinal) {
        finalText += transcript;
      } else {
        interim += transcript;
      }
    }

    const latestText = (finalText || interim).trim();
    if (latestText) {
      pendingRecognitionText = latestText;
    }

    if (latestText && typeof window.onSpeechInterimResult === 'function') {
      window.onSpeechInterimResult(latestText);
    }

    if (finalText && typeof window.onSpeechFinalResult === 'function') {
      emittedFinalText = true;
      window.onSpeechFinalResult(finalText.trim());
    }
  };

  recognition.onnomatch = function() {
    if (token !== activeRecognitionToken) {
      return;
    }
    if (typeof window.onSpeechError === 'function') {
      window.onSpeechError('no-speech');
    }
  };

  recognition.onerror = function(event) {
    if (token !== activeRecognitionToken) {
      return;
    }

    const errorCode =
      event && typeof event.error === 'string' ? event.error : 'unknown';

    if (errorCode !== 'aborted') {
      emitFinalIfNeeded();
    }

    if (typeof window.onSpeechError === 'function') {
      window.onSpeechError(errorCode);
    }
  };

  recognition.onend = function() {
    finishRecognition(token);
  };

  try {
    recognition.start();
    return true;
  } catch (_) {
    speechRecognitionInstance = null;
    pendingRecognitionText = '';
    emittedFinalText = false;
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
  ) {
    return;
  }

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
