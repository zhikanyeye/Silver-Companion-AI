from fastapi.testclient import TestClient
import pytest

import app as tts_app


client = TestClient(tts_app.app)


class _FakeGenerator:
    def __init__(self) -> None:
        self.calls: list[tuple[str, str, float]] = []

    def generate(self, text: str, voice: str, speed: float) -> bytes:
        self.calls.append((text, voice, speed))
        return b"RIFFfake-wav-data"


def test_tts_returns_audio_for_valid_text(monkeypatch: pytest.MonkeyPatch) -> None:
    generator = _FakeGenerator()
    monkeypatch.setattr(tts_app, "_generator", generator)

    response = client.post(
        "/tts",
        json={"text": "您好，今天感觉怎么样？", "voice": "Bella", "speed": 1.0},
    )

    assert response.status_code == 200
    assert response.headers["content-type"].startswith("audio/")
    assert response.content == b"RIFFfake-wav-data"
    assert generator.calls == [("您好，今天感觉怎么样？", "Bella", 1.0)]


def test_tts_rejects_empty_text() -> None:
    response = client.post("/tts", json={"text": "", "voice": "Bella"})

    assert response.status_code == 422


def test_tts_rejects_overlong_text() -> None:
    response = client.post(
        "/tts",
        json={"text": "a" * 1201, "voice": "Bella", "speed": 1.0},
    )

    assert response.status_code == 422


def test_tts_returns_503_when_generation_fails(monkeypatch: pytest.MonkeyPatch) -> None:
    class _FailingGenerator:
        def generate(self, text: str, voice: str, speed: float) -> bytes:
            raise RuntimeError("generation failed")

    monkeypatch.setattr(tts_app, "_generator", _FailingGenerator())

    response = client.post(
        "/tts",
        json={"text": "您好", "voice": "Bella", "speed": 1.0},
    )

    assert response.status_code == 503
    assert response.json() == {"error": "TTS service temporarily unavailable"}
