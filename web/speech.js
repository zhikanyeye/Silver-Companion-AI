let speechRecognitionInstance = null;
let activeRecognitionToken = 0;
let finalRecognitionText = '';
let interimRecognitionText = '';
let lastEmittedFinalText = '';
let noSpeechTimeoutId = null;

const NO_SPEECH_TIMEOUT_MS = 8000;

function resolveSpeechRecognitionCtor() {
  if (typeof window === 'undefined') return null;
  return window.SpeechRecognition || window.webkitSpeechRecognition || null;
}

function isRecognitionSecureContext() {
  if (typeof window === 'undefined') return false;
  if (window.isSecureContext) return true;

  const hostname = window.location && typeof window.location.hostname === 'string'
    ? window.location.hostname
    : '';
  return hostname === 'localhost' || hostname === '127.0.0.1';
}

function getCombinedRecognitionText() {
  return `${finalRecognitionText} ${interimRecognitionText}`.trim();
}

function resetRecognitionState() {
  finalRecognitionText = '';
  interimRecognitionText = '';
  lastEmittedFinalText = '';
}

function clearNoSpeechTimeout() {
  if (noSpeechTimeoutId !== null) {
    clearTimeout(noSpeechTimeoutId);
    noSpeechTimeoutId = null;
  }
}

function restartNoSpeechTimeout(token) {
  clearNoSpeechTimeout();
  noSpeechTimeoutId = setTimeout(() => {
    if (token !== activeRecognitionToken) {
      return;
    }

    if (speechRecognitionInstance !== null) {
      try {
        speechRecognitionInstance.stop();
      } catch (_) {}
    }

    if (typeof window.onSpeechError === 'function') {
      window.onSpeechError('no-speech');
    }
  }, NO_SPEECH_TIMEOUT_MS);
}

function emitFinalIfNeeded() {
  const combinedText = getCombinedRecognitionText();
  if (
    combinedText &&
    combinedText !== lastEmittedFinalText &&
    typeof window.onSpeechFinalResult === 'function'
  ) {
    lastEmittedFinalText = combinedText;
    window.onSpeechFinalResult(combinedText);
  }
}

function finishRecognition(token) {
  if (token !== activeRecognitionToken) {
    return;
  }

  clearNoSpeechTimeout();
  emitFinalIfNeeded();
  resetRecognitionState();
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
  return (
    isRecognitionSecureContext() &&
    resolveSpeechRecognitionCtor() !== null
  );
};

window.speechRecognitionUnsupportedReason = function() {
  if (!isRecognitionSecureContext()) {
    return 'insecure-context';
  }

  if (resolveSpeechRecognitionCtor() === null) {
    return 'unsupported-browser';
  }

  return 'supported';
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
  if (!isRecognitionSecureContext()) {
    if (typeof window.onSpeechError === 'function') {
      window.onSpeechError('insecure-context');
    }
    return false;
  }
  if (SpeechRecognitionCtor === null) {
    if (typeof window.onSpeechError === 'function') {
      window.onSpeechError('unsupported-browser');
    }
    return false;
  }

  activeRecognitionToken += 1;
  const token = activeRecognitionToken;

  if (speechRecognitionInstance !== null) {
    try {
      speechRecognitionInstance.abort();
    } catch (_) {}
  }

  const recognition = new SpeechRecognitionCtor();
  speechRecognitionInstance = recognition;
  resetRecognitionState();

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
    restartNoSpeechTimeout(token);
  };

  recognition.onresult = function(event) {
    if (token !== activeRecognitionToken) {
      return;
    }

    restartNoSpeechTimeout(token);

    const finalParts = [];
    const interimParts = [];

    for (let i = 0; i < event.results.length; i += 1) {
      const transcript = (event.results[i][0].transcript || '').trim();
      if (!transcript) {
        continue;
      }

      if (event.results[i].isFinal) {
        finalParts.push(transcript);
      } else {
        interimParts.push(transcript);
      }
    }

    finalRecognitionText = finalParts.join(' ').trim();
    interimRecognitionText = interimParts.join(' ').trim();

    const combinedText = getCombinedRecognitionText();

    if (combinedText && typeof window.onSpeechInterimResult === 'function') {
      window.onSpeechInterimResult(combinedText);
    }

    if (
      finalRecognitionText &&
      finalRecognitionText !== lastEmittedFinalText &&
      typeof window.onSpeechFinalResult === 'function'
    ) {
      lastEmittedFinalText = finalRecognitionText;
      window.onSpeechFinalResult(finalRecognitionText);
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

    clearNoSpeechTimeout();
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
    clearNoSpeechTimeout();
    speechRecognitionInstance = null;
    resetRecognitionState();
    return false;
  }
};

window.speechStopRecognition = function() {
  if (speechRecognitionInstance === null) return;
  clearNoSpeechTimeout();
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
