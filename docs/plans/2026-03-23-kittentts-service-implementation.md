# KittenTTS Service Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a deployable FastAPI + KittenTTS service on Railway and integrate the Flutter web client so AI replies can play reliable generated audio with browser-speech fallback.

**Architecture:** Keep the existing Pages deployment untouched and add TTS as a separate Python service. The Flutter app will call the TTS API first, play returned audio when available, and fall back to `WebSpeechService` only when the TTS path fails or is not configured.

**Tech Stack:** Python, FastAPI, KittenTTS, Railway, Flutter web, Dart HTTP/audio playback, `flutter test`

---

### Task 1: Scaffold the Python TTS service contract and failing service tests

**Files:**
- Create: `services/tts/requirements.txt`
- Create: `services/tts/app.py`
- Create: `services/tts/test_app.py`
- Create: `services/tts/README.md`

**Step 1: Write the failing test**

Add Python API tests covering:
- valid `POST /tts` returns audio response
- empty text is rejected
- overlong text is rejected

**Step 2: Run test to verify it fails**

Run: `python -m pytest services/tts/test_app.py -q`
Expected: FAIL because the TTS service does not exist yet.

**Step 3: Write minimal implementation**

Create a minimal FastAPI service contract and placeholder endpoint that satisfies the test structure before real model wiring.

**Step 4: Run test to verify it passes**

Run: `python -m pytest services/tts/test_app.py -q`
Expected: PASS for the contract-level behavior.

**Step 5: Commit**

```bash
git add services/tts/requirements.txt services/tts/app.py services/tts/test_app.py services/tts/README.md
git commit -m "feat: scaffold KittenTTS API service"
```

### Task 2: Wire KittenTTS generation into the FastAPI service

**Files:**
- Modify: `services/tts/app.py`
- Modify: `services/tts/test_app.py`
- Create: `services/tts/railway.json`

**Step 1: Write the failing test**

Extend service tests so the endpoint must return generated audio bytes with the expected content type and proper validation behavior.

**Step 2: Run test to verify it fails**

Run: `python -m pytest services/tts/test_app.py -q`
Expected: FAIL because the service still uses a placeholder implementation.

**Step 3: Write minimal implementation**

Integrate `KittenTTS` into the endpoint, choose a small default model, and return WAV audio bytes.

**Step 4: Run test to verify it passes**

Run: `python -m pytest services/tts/test_app.py -q`
Expected: PASS with real or mocked audio generation behavior.

**Step 5: Commit**

```bash
git add services/tts/app.py services/tts/test_app.py services/tts/railway.json
git commit -m "feat: integrate KittenTTS generation"
```

### Task 3: Add Flutter-side TTS client and fallback behavior

**Files:**
- Create: `lib/services/tts_client.dart`
- Modify: `lib/features/chat/chat_controller.dart`
- Modify: `lib/features/chat/chat_page.dart`
- Modify: `lib/config/app_config.dart`
- Modify: `lib/config/config_loader.dart`
- Create: `test/services/tts_client_test.dart`
- Modify: `test/features/chat/chat_controller_test.dart`

**Step 1: Write the failing test**

Add tests for:
- successful TTS client response returns playable bytes or URL/object handle
- chat controller prefers TTS service first
- chat controller falls back to `WebSpeechService` when TTS fails

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/services/tts_client_test.dart test/features/chat/chat_controller_test.dart`
Expected: FAIL because there is no dedicated TTS client or fallback path yet.

**Step 3: Write minimal implementation**

Implement:
- TTS client with configurable base URL
- controller integration for TTS-first, WebSpeech-fallback
- chat page playback controls wired to the new path

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/services/tts_client_test.dart test/features/chat/chat_controller_test.dart test/features/chat/chat_page_shell_test.dart`
Expected: PASS with visible and testable fallback behavior.

**Step 5: Commit**

```bash
git add lib/services/tts_client.dart lib/features/chat/chat_controller.dart lib/features/chat/chat_page.dart lib/config/app_config.dart lib/config/config_loader.dart test/services/tts_client_test.dart test/features/chat/chat_controller_test.dart
git commit -m "feat: add TTS client with browser fallback"
```

### Task 4: Add deployment docs and verify end-to-end integration

**Files:**
- Modify: `README.md`
- Create: `docs/kittentts-railway-deployment.md`
- Verify only: `services/tts/*`
- Verify only: `lib/services/tts_client.dart`

**Step 1: Write the failing test**

If needed, add one small config or integration test covering absence/presence of the TTS base URL.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/services/tts_client_test.dart`
Expected: FAIL until config behavior is fully documented and implemented.

**Step 3: Write minimal implementation**

Document Railway deployment, required env vars, and front-end config wiring.

**Step 4: Run test to verify it passes**

Run: `python -m pytest services/tts/test_app.py -q && E:/tools/flutter/bin/flutter.bat test`
Expected: PASS for service tests and full Flutter suite.

**Step 5: Commit**

```bash
git add README.md docs/kittentts-railway-deployment.md services/tts/ lib/services/tts_client.dart test/services/tts_client_test.dart docs/plans/2026-03-23-kittentts-service-design.md docs/plans/2026-03-23-kittentts-service-implementation.md
git commit -m "feat: add KittenTTS deployment path"
```
