let mediaRecorderInstance = null;
let mediaStreamInstance = null;
let activeRecognitionToken = 0;
let recordedChunks = [];
let recordingMimeType = '';
let uploadInFlight = false;

function isRecognitionSecureContext() {
  if (typeof window === 'undefined') return false;
  if (window.isSecureContext) return true;

  const hostname =
    window.location && typeof window.location.hostname === 'string'
      ? window.location.hostname
      : '';
  return hostname === 'localhost' || hostname === '127.0.0.1';
}

function hasRecordingSupport() {
  return (
    typeof window !== 'undefined' &&
    typeof window.MediaRecorder !== 'undefined' &&
    typeof navigator !== 'undefined' &&
    navigator.mediaDevices &&
    typeof navigator.mediaDevices.getUserMedia === 'function'
  );
}

function resolveRecordingMimeType() {
  if (
    typeof window === 'undefined' ||
    typeof window.MediaRecorder === 'undefined' ||
    typeof window.MediaRecorder.isTypeSupported !== 'function'
  ) {
    return '';
  }

  const candidates = [
    'audio/webm;codecs=opus',
    'audio/webm',
    'audio/mp4',
    'audio/ogg;codecs=opus',
  ];

  for (const candidate of candidates) {
    try {
      if (window.MediaRecorder.isTypeSupported(candidate)) {
        return candidate;
      }
    } catch (_) {}
  }

  return '';
}

function stopActiveStream() {
  if (mediaStreamInstance === null) return;
  try {
    const tracks = mediaStreamInstance.getTracks();
    for (const track of tracks) {
      track.stop();
    }
  } catch (_) {}
  mediaStreamInstance = null;
}

function resetRecognitionState() {
  mediaRecorderInstance = null;
  recordedChunks = [];
  recordingMimeType = '';
  stopActiveStream();
}

function emitSpeechError(errorCode) {
  if (typeof window.onSpeechError === 'function') {
    window.onSpeechError(errorCode);
  }
}

function emitSpeechStart() {
  if (typeof window.onSpeechStart === 'function') {
    window.onSpeechStart();
  }
}

function emitSpeechEnd() {
  if (typeof window.onSpeechEnd === 'function') {
    window.onSpeechEnd();
  }
}

function emitSpeechFinalResult(text) {
  if (typeof window.onSpeechFinalResult === 'function') {
    window.onSpeechFinalResult(text);
  }
}

function mapGetUserMediaError(error) {
  const name =
    error && typeof error.name === 'string' ? error.name.toLowerCase() : '';

  if (name === 'notallowederror' || name === 'securityerror') {
    return 'not-allowed';
  }
  if (
    name === 'notfounderror' ||
    name === 'devicesnotfounderror' ||
    name === 'notreadableerror' ||
    name === 'trackstarterror'
  ) {
    return 'audio-capture';
  }

  return 'audio-capture';
}

async function uploadRecordedAudio(token) {
  if (token !== activeRecognitionToken) {
    resetRecognitionState();
    emitSpeechEnd();
    return;
  }

  const blob = new Blob(recordedChunks, {
    type: recordingMimeType || 'audio/webm',
  });

  resetRecognitionState();

  if (blob.size === 0) {
    emitSpeechError('no-speech');
    emitSpeechEnd();
    return;
  }

  uploadInFlight = true;

  try {
    const formData = new FormData();
    formData.append('file', blob, 'voice-input.webm');

    const response = await fetch('/api/stt', {
      method: 'POST',
      body: formData,
    });

    let payload = null;
    try {
      payload = await response.json();
    } catch (_) {}

    if (!response.ok) {
      const upstreamError =
        payload && typeof payload.error === 'string' ? payload.error : '';
      const normalized = upstreamError.trim().toLowerCase();
      if (
        normalized.includes('not configured') ||
        normalized.includes('missing')
      ) {
        emitSpeechError('stt-unavailable');
      } else {
        emitSpeechError('network');
      }
      return;
    }

    const text =
      payload && typeof payload.text === 'string' ? payload.text.trim() : '';

    if (!text) {
      emitSpeechError('no-speech');
      return;
    }

    emitSpeechFinalResult(text);
  } catch (_) {
    emitSpeechError('network');
  } finally {
    uploadInFlight = false;
    emitSpeechEnd();
  }
}

window.speechIsSupported = function() {
  return (
    window.speechRecognitionIsSupported() ||
    window.speechPlaybackIsSupported()
  );
};

window.speechRecognitionIsSupported = function() {
  return isRecognitionSecureContext() && hasRecordingSupport();
};

window.speechRecognitionUnsupportedReason = function() {
  if (!isRecognitionSecureContext()) {
    return 'insecure-context';
  }

  if (!hasRecordingSupport()) {
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
  if (!isRecognitionSecureContext()) {
    emitSpeechError('insecure-context');
    return false;
  }

  if (!hasRecordingSupport()) {
    emitSpeechError('unsupported-browser');
    return false;
  }

  if (uploadInFlight || mediaRecorderInstance !== null) {
    emitSpeechError('busy');
    return false;
  }

  activeRecognitionToken += 1;
  const token = activeRecognitionToken;

  navigator.mediaDevices
    .getUserMedia({audio: true})
    .then((stream) => {
      if (token !== activeRecognitionToken) {
        try {
          const tracks = stream.getTracks();
          for (const track of tracks) {
            track.stop();
          }
        } catch (_) {}
        return;
      }

      mediaStreamInstance = stream;
      recordedChunks = [];
      recordingMimeType = resolveRecordingMimeType();

      const options = recordingMimeType ? {mimeType: recordingMimeType} : {};
      const recorder = new MediaRecorder(stream, options);
      mediaRecorderInstance = recorder;

      recorder.ondataavailable = function(event) {
        if (event && event.data && event.data.size > 0) {
          recordedChunks.push(event.data);
        }
      };

      recorder.onerror = function() {
        resetRecognitionState();
        emitSpeechError('audio-capture');
        emitSpeechEnd();
      };

      recorder.onstop = function() {
        uploadRecordedAudio(token);
      };

      try {
        recorder.start();
        emitSpeechStart();
      } catch (_) {
        resetRecognitionState();
        emitSpeechError('audio-capture');
        emitSpeechEnd();
      }
    })
    .catch((error) => {
      if (token !== activeRecognitionToken) {
        return;
      }

      resetRecognitionState();
      emitSpeechError(mapGetUserMediaError(error));
      emitSpeechEnd();
    });

  return true;
};

window.speechStopRecognition = function() {
  if (mediaRecorderInstance === null) {
    activeRecognitionToken += 1;
    resetRecognitionState();
    emitSpeechEnd();
    return;
  }

  try {
    if (mediaRecorderInstance.state !== 'inactive') {
      mediaRecorderInstance.stop();
    }
  } catch (_) {
    resetRecognitionState();
    emitSpeechError('audio-capture');
    emitSpeechEnd();
  }
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
