# KittenTTS Service

Standalone FastAPI text-to-speech service intended for Railway deployment.

## Local setup

```bash
python -m venv .venv
.venv\Scripts\python.exe -m pip install -r requirements.txt
```

## Run locally

```bash
.venv\Scripts\uvicorn.exe app:app --host 0.0.0.0 --port 8000
```

## Test locally

```bash
.venv\Scripts\python.exe -m pytest test_app.py -q
```

## Endpoint

`POST /tts`

Example body:

```json
{
  "text": "您好，今天感觉怎么样？",
  "voice": "Bella",
  "speed": 1.0
}
```

Returns `audio/wav` on success.

## Environment variables

- `KITTEN_MODEL_NAME` - optional, defaults to `KittenML/kitten-tts-nano-0.8-int8`
- `KITTEN_DEFAULT_VOICE` - optional, defaults to `Bella`
