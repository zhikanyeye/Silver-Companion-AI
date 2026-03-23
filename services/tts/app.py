from __future__ import annotations

from io import BytesIO
import os
import wave

import numpy as np

from fastapi import FastAPI
from fastapi.responses import JSONResponse, Response
from kittentts import KittenTTS
from pydantic import BaseModel, Field


app = FastAPI(title="Silver Companion TTS Service")


class TTSRequest(BaseModel):
    text: str = Field(min_length=1, max_length=1200)
    voice: str = Field(default="Bella", min_length=1, max_length=64)
    speed: float = Field(default=1.0, ge=0.5, le=2.0)


class AudioGenerator:
    def generate(self, text: str, voice: str, speed: float) -> bytes:
        raise NotImplementedError


class KittenAudioGenerator(AudioGenerator):
    def __init__(self) -> None:
        self._model_name = os.getenv("KITTEN_MODEL_NAME", "KittenML/kitten-tts-nano-0.8-int8")
        self._default_voice = os.getenv("KITTEN_DEFAULT_VOICE", "Bella")
        self._model: KittenTTS | None = None

    def _load_model(self) -> KittenTTS:
        if self._model is None:
            self._model = KittenTTS(self._model_name)
        return self._model

    def generate(self, text: str, voice: str, speed: float) -> bytes:
        model = self._load_model()
        voice_name = voice or self._default_voice
        audio = model.generate(text, voice=voice_name, speed=speed)
        return _audio_array_to_wav_bytes(audio)


_generator: AudioGenerator = KittenAudioGenerator()


def _audio_array_to_wav_bytes(audio: np.ndarray) -> bytes:
    sample_rate = 24000
    clipped = np.clip(audio, -1.0, 1.0)
    pcm = (clipped * 32767).astype(np.int16)

    buffer = BytesIO()
    with wave.open(buffer, "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(pcm.tobytes())

    return buffer.getvalue()


@app.post("/tts")
def synthesize_speech(request: TTSRequest) -> Response:
    try:
        audio = _generator.generate(request.text, request.voice, request.speed)
    except Exception:
        return JSONResponse(
            status_code=503,
            content={"error": "TTS service temporarily unavailable"},
        )
    return Response(content=audio, media_type="audio/wav")
