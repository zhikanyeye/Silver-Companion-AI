# Polish And Speech Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Deliver a second visual polish pass across key pages and make AI reply speech playback visible, controllable, and reliable enough for production use on web.

**Architecture:** Refine existing page shells rather than redesigning architecture again. For speech, keep the existing `WebSpeechService` path but add explicit UI affordances, isolate failure handling, and verify behavior through controller/page-level tests so the feature is no longer hidden behind implicit side effects.

**Tech Stack:** Flutter, Dart, Material 3, widget tests, existing web speech bridge, `flutter test`

---

### Task 1: Add failing tests for visible speech controls and second-pass page structure

**Files:**
- Modify: `test/features/chat/chat_page_shell_test.dart`
- Modify: `test/features/landing/landing_page_test.dart`
- Modify: `test/widgets/elderly_home_test.dart`
- Modify: `test/widgets/child_home_test.dart`

**Step 1: Write the failing test**

Add assertions that:
- chat page exposes a speech toggle and replay controls for assistant messages
- landing page keeps a stronger top entry shell marker
- elderly and child home pages preserve a clearer hero / high-priority region structure after polish

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/chat/chat_page_shell_test.dart test/features/landing/landing_page_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart`
Expected: FAIL because the second-pass polish markers and visible speech controls do not exist yet.

**Step 3: Write minimal implementation**

Do not change production code yet. Let the tests define the next-pass target behavior.

**Step 4: Run test to verify it fails for the right reason**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/chat/chat_page_shell_test.dart test/features/landing/landing_page_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart`
Expected: FAIL due to missing controls / missing page-shell polish markers.

**Step 5: Commit**

```bash
git add test/features/chat/chat_page_shell_test.dart test/features/landing/landing_page_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart
git commit -m "test: define second-pass polish expectations"
```

### Task 2: Refine landing, elderly, and child page polish

**Files:**
- Modify: `lib/features/landing/landing_page.dart`
- Modify: `lib/widgets/brand_hero.dart`
- Modify: `lib/features/elderly/elderly_home_page.dart`
- Modify: `lib/features/elderly/elderly_activities_page.dart`
- Modify: `lib/features/child/child_home_page.dart`
- Test: `test/features/landing/landing_page_test.dart`
- Test: `test/widgets/elderly_home_test.dart`
- Test: `test/widgets/child_home_test.dart`

**Step 1: Write the failing test**

Use the failing tests from Task 1 as the target for the second-pass structural polish.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart`
Expected: FAIL because current page shells are only first-pass unified, not second-pass polished.

**Step 3: Write minimal implementation**

Refine:
- landing top action shell and hero rhythm
- elderly hero emphasis and action hierarchy
- child overview density and state-strip visual consistency
- activities page card polish where needed

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart`
Expected: PASS with preserved navigation behavior.

**Step 5: Commit**

```bash
git add lib/features/landing/landing_page.dart lib/widgets/brand_hero.dart lib/features/elderly/elderly_home_page.dart lib/features/elderly/elderly_activities_page.dart lib/features/child/child_home_page.dart test/features/landing/landing_page_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart
git commit -m "feat: refine key page polish"
```

### Task 3: Make speech playback visible and controllable in chat

**Files:**
- Modify: `lib/features/chat/chat_page.dart`
- Modify: `lib/features/chat/chat_controller.dart`
- Modify: `lib/services/web_speech_service.dart`
- Test: `test/features/chat/chat_page_shell_test.dart`
- Test: `test/features/chat/chat_controller_test.dart`

**Step 1: Write the failing test**

Add tests for:
- speech toggle visibility and state changes
- replay button on assistant messages
- explicit speech-service invocation when replay is tapped

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/chat/chat_page_shell_test.dart test/features/chat/chat_controller_test.dart`
Expected: FAIL because chat page has no visible speech controls and replay path yet.

**Step 3: Write minimal implementation**

Implement:
- chat-level auto-play toggle
- replay button on assistant messages
- controller methods for replay and speech-enabled state
- web speech service adjustments only as needed to support explicit playback and graceful no-op behavior

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/chat/chat_page_shell_test.dart test/features/chat/chat_controller_test.dart`
Expected: PASS with visible, testable speech controls.

**Step 5: Commit**

```bash
git add lib/features/chat/chat_page.dart lib/features/chat/chat_controller.dart lib/services/web_speech_service.dart test/features/chat/chat_page_shell_test.dart test/features/chat/chat_controller_test.dart
git commit -m "feat: add visible chat speech controls"
```

### Task 4: Verify the full app after polish and speech work

**Files:**
- Verify only: `lib/features/landing/landing_page.dart`
- Verify only: `lib/widgets/brand_hero.dart`
- Verify only: `lib/features/elderly/elderly_home_page.dart`
- Verify only: `lib/features/elderly/elderly_activities_page.dart`
- Verify only: `lib/features/child/child_home_page.dart`
- Verify only: `lib/features/chat/chat_page.dart`
- Verify only: `lib/features/chat/chat_controller.dart`
- Verify only: `lib/services/web_speech_service.dart`

**Step 1: Run targeted tests**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/chat/chat_page_shell_test.dart test/features/chat/chat_controller_test.dart test/features/landing/landing_page_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart`
Expected: PASS.

**Step 2: Run full test suite**

Run: `E:/tools/flutter/bin/flutter.bat test`
Expected: PASS with no regressions.

**Step 3: Review diff**

Ensure the change stays focused on second-pass polish and speech visibility, not unrelated refactors.

**Step 4: Verify git status**

Run: `git status --short`
Expected: only intended polish/speech files are modified.

**Step 5: Commit**

```bash
git add lib/features/landing/landing_page.dart lib/widgets/brand_hero.dart lib/features/elderly/elderly_home_page.dart lib/features/elderly/elderly_activities_page.dart lib/features/child/child_home_page.dart lib/features/chat/chat_page.dart lib/features/chat/chat_controller.dart lib/services/web_speech_service.dart test/features/chat/chat_page_shell_test.dart test/features/chat/chat_controller_test.dart test/features/landing/landing_page_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart docs/plans/2026-03-22-polish-and-speech-design.md docs/plans/2026-03-22-polish-and-speech-implementation.md
git commit -m "feat: polish key pages and add speech controls"
```
