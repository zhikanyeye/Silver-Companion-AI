# 银龄智伴 Demo Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Flutter Web-first demo of “银龄智伴” with elderly + child views, real AI chat via OpenRouter, and social-feed styled community help.

**Architecture:** Single Flutter app with two primary entry routes (elderly/child). Local mock data for community feed and family status. OpenRouter client + prompt builder for empathy and anti-fraud messaging. Browser speech via Web Speech API for ASR/TTS.

**Tech Stack:** Flutter (Web), Dart, http, provider, shared_preferences, JS interop for Web Speech API.

---

### Task 1: Initialize Flutter project

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `test/widget_test.dart`

**Step 1: Write the failing test**

Create `test/widget_test.dart` with the default Flutter template test, then run it before code exists.

**Step 2: Run test to verify it fails**

Run: `flutter test`
Expected: FAIL because Flutter project not initialized.

**Step 3: Write minimal implementation**

Run: `flutter create .`

**Step 4: Run test to verify it passes**

Run: `flutter test`
Expected: PASS for default counter test.

**Step 5: Commit**

```bash
git add pubspec.yaml lib/main.dart test/widget_test.dart
git commit -m "chore: initialize flutter app"
```

---

### Task 2: Add core dependencies and app scaffold

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/app.dart`
- Modify: `lib/main.dart`

**Step 1: Write the failing test**

Create `test/widgets/app_boot_test.dart` to assert the app renders a home selector (elderly/child).

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/app_boot_test.dart`
Expected: FAIL because `App` and home selector not implemented.

**Step 3: Write minimal implementation**

- Add dependencies: `provider`, `http`, `shared_preferences`, `js` in `pubspec.yaml`.
- Create `lib/app.dart` with `MaterialApp` and a simple home selector.
- Update `lib/main.dart` to `runApp(const App());`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/app_boot_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add pubspec.yaml lib/app.dart lib/main.dart test/widgets/app_boot_test.dart
git commit -m "chore: add app scaffold and dependencies"
```

---

### Task 3: Define routes and theme

**Files:**
- Create: `lib/routes.dart`
- Create: `lib/theme/app_theme.dart`
- Modify: `lib/app.dart`
- Test: `test/widgets/routes_test.dart`

**Step 1: Write the failing test**

`test/widgets/routes_test.dart` should verify that tapping Elderly or Child navigates to the correct route.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/routes_test.dart`
Expected: FAIL because routes not defined.

**Step 3: Write minimal implementation**

- Implement named routes for elderly and child roots.
- Add a high-contrast theme in `app_theme.dart` (large font scale, bold buttons).

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/routes_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/routes.dart lib/theme/app_theme.dart lib/app.dart test/widgets/routes_test.dart
git commit -m "feat: add routes and theme"
```

---

### Task 4: Chat domain models and anti-fraud rules

**Files:**
- Create: `lib/features/chat/chat_message.dart`
- Create: `lib/features/chat/scam_rules.dart`
- Test: `test/features/chat/scam_rules_test.dart`

**Step 1: Write the failing test**

`scam_rules_test.dart` should assert keyword detection for words like “转账/养老金/安全账户”.

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/chat/scam_rules_test.dart`
Expected: FAIL because rules not implemented.

**Step 3: Write minimal implementation**

Implement `ScamRules.containsRisk(text)` with a keyword set and basic normalization.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/chat/scam_rules_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/chat/chat_message.dart lib/features/chat/scam_rules.dart test/features/chat/scam_rules_test.dart
git commit -m "feat: add chat models and scam detection"
```

---

### Task 5: Prompt builder with empathy + anti-fraud system message

**Files:**
- Create: `lib/features/chat/prompt_builder.dart`
- Test: `test/features/chat/prompt_builder_test.dart`

**Step 1: Write the failing test**

Verify prompt builder includes: empathy role, anti-fraud instruction, and last N messages.

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/chat/prompt_builder_test.dart`
Expected: FAIL because builder not implemented.

**Step 3: Write minimal implementation**

Implement `PromptBuilder.build()` to produce OpenRouter messages array.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/chat/prompt_builder_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/chat/prompt_builder.dart test/features/chat/prompt_builder_test.dart
git commit -m "feat: add prompt builder"
```

---

### Task 6: OpenRouter client and repository

**Files:**
- Create: `lib/services/openrouter_client.dart`
- Create: `lib/features/chat/chat_repository.dart`
- Test: `test/services/openrouter_client_test.dart`

**Step 1: Write the failing test**

Mock HTTP response to verify request body and parse response text.

**Step 2: Run test to verify it fails**

Run: `flutter test test/services/openrouter_client_test.dart`
Expected: FAIL because client not implemented.

**Step 3: Write minimal implementation**

- Read API key from `const String.fromEnvironment('OPENROUTER_API_KEY')`.
- Implement POST to OpenRouter `/chat/completions`.
- Parse the first choice message content.

**Step 4: Run test to verify it passes**

Run: `flutter test test/services/openrouter_client_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/services/openrouter_client.dart lib/features/chat/chat_repository.dart test/services/openrouter_client_test.dart
git commit -m "feat: add openrouter client"
```

---

### Task 7: Web Speech API integration (ASR + TTS)

**Files:**
- Create: `web/speech.js`
- Create: `lib/services/web_speech_service.dart`
- Test: `test/services/web_speech_service_test.dart`

**Step 1: Write the failing test**

Test a small helper `isSpeechSupported()` returning false when not web.

**Step 2: Run test to verify it fails**

Run: `flutter test test/services/web_speech_service_test.dart`
Expected: FAIL because helper not implemented.

**Step 3: Write minimal implementation**

- Add JS wrappers for `SpeechRecognition` and `speechSynthesis` in `web/speech.js`.
- Implement Dart interop in `web_speech_service.dart`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/services/web_speech_service_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add web/speech.js lib/services/web_speech_service.dart test/services/web_speech_service_test.dart
git commit -m "feat: add web speech service"
```

---

### Task 8: Elderly home + AI chat UI

**Files:**
- Create: `lib/features/elderly/elderly_home_page.dart`
- Create: `lib/features/chat/chat_page.dart`
- Create: `lib/features/chat/chat_controller.dart`
- Test: `test/widgets/elderly_home_test.dart`

**Step 1: Write the failing test**

Test that Elderly Home renders large buttons and avatar entry.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/elderly_home_test.dart`
Expected: FAIL because UI not implemented.

**Step 3: Write minimal implementation**

- Build Elderly home with large buttons and floating avatar.
- `ChatPage` supports text input + voice button + TTS playback.
- `ChatController` handles loading, error, and scam warning.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/elderly_home_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/elderly/elderly_home_page.dart lib/features/chat/chat_page.dart lib/features/chat/chat_controller.dart test/widgets/elderly_home_test.dart
git commit -m "feat: add elderly home and chat UI"
```

---

### Task 9: Community feed (Weibo/Xiaohongshu style)

**Files:**
- Create: `lib/features/community/community_feed_page.dart`
- Create: `lib/features/community/mock_posts.dart`
- Test: `test/widgets/community_feed_test.dart`

**Step 1: Write the failing test**

Ensure feed renders cards with tag + location + time.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/community_feed_test.dart`
Expected: FAIL because feed not implemented.

**Step 3: Write minimal implementation**

- Card layout with avatar, username, tag chips, content, meta row.
- Floating “发布互助” button (demo).

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/community_feed_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/community/community_feed_page.dart lib/features/community/mock_posts.dart test/widgets/community_feed_test.dart
git commit -m "feat: add community feed"
```

---

### Task 10: Child-side dashboard + alerts

**Files:**
- Create: `lib/features/child/child_home_page.dart`
- Create: `lib/features/child/mock_family_data.dart`
- Test: `test/widgets/child_home_test.dart`

**Step 1: Write the failing test**

Verify overview shows status cards and alert list.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/child_home_test.dart`
Expected: FAIL because child UI not implemented.

**Step 3: Write minimal implementation**

- Render activity and mood trends (static cards).
- Display alert timeline list.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/child_home_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/child/child_home_page.dart lib/features/child/mock_family_data.dart test/widgets/child_home_test.dart
git commit -m "feat: add child dashboard"
```

---

### Task 11: Settings for API key and model

**Files:**
- Create: `lib/features/settings/settings_page.dart`
- Create: `lib/services/settings_store.dart`
- Test: `test/features/settings/settings_store_test.dart`

**Step 1: Write the failing test**

Test `SettingsStore` read/write with `shared_preferences` mock.

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/settings/settings_store_test.dart`
Expected: FAIL because store not implemented.

**Step 3: Write minimal implementation**

- Store API key + model name locally.
- If empty, use environment default and show warning banner.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/settings/settings_store_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/settings/settings_page.dart lib/services/settings_store.dart test/features/settings/settings_store_test.dart
git commit -m "feat: add settings for api key"
```

---

### Task 12: Final polish and demo script

**Files:**
- Modify: `lib/app.dart`
- Create: `docs/demo-script.md`

**Step 1: Write the failing test**

Add a small widget test to ensure Settings entry is accessible from home.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/settings_entry_test.dart`
Expected: FAIL because entry not connected.

**Step 3: Write minimal implementation**

- Add Settings entry in home selector.
- Write `docs/demo-script.md` with 3–5 step演示流程。

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/settings_entry_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/app.dart docs/demo-script.md test/widgets/settings_entry_test.dart
git commit -m "docs: add demo script and settings entry"
```
