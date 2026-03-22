# Server Model Priority Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make Cloudflare Pages server config win over client-provided model values so `AI_MODEL_NAME` truly controls production model selection.

**Architecture:** Fix the issue at both boundaries: the Pages Function should prefer `AI_MODEL_NAME`, and the Flutter HTTP client should stop sending a model field by default. Add one function-level Node regression test file plus Dart client tests so both layers are locked down.

**Tech Stack:** Cloudflare Pages Functions, JavaScript, Node test runner, Flutter/Dart, `flutter test`

---

### Task 1: Add failing regression tests for model-priority behavior

**Files:**
- Create: `functions/api/chat.test.mjs`
- Modify: `test/services/openrouter_client_test.dart`

**Step 1: Write the failing test**

Add a function test covering:
- env model overrides request-body model
- request-body model only applies when env model is absent

Update the Dart client test to expect that the client request body no longer includes `model`.

**Step 2: Run test to verify it fails**

Run: `node --test functions/api/chat.test.mjs && E:/tools/flutter/bin/flutter.bat test test/services/openrouter_client_test.dart`
Expected: FAIL because the function still prefers request-body model and the client still sends model.

**Step 3: Write minimal implementation**

Do not change production code yet. Let the failing tests define the target behavior.

**Step 4: Run test to verify it fails for the right reason**

Run: `node --test functions/api/chat.test.mjs && E:/tools/flutter/bin/flutter.bat test test/services/openrouter_client_test.dart`
Expected: FAIL due to wrong model-priority behavior, not test harness errors.

**Step 5: Commit**

```bash
git add functions/api/chat.test.mjs test/services/openrouter_client_test.dart
git commit -m "test: define server model priority behavior"
```

### Task 2: Implement server-priority model selection and client cleanup

**Files:**
- Modify: `functions/api/chat.js`
- Modify: `lib/services/openrouter_client.dart`
- Test: `functions/api/chat.test.mjs`
- Test: `test/services/openrouter_client_test.dart`

**Step 1: Write the failing test**

Use the failing tests from Task 1 as the target for the fix.

**Step 2: Run test to verify it fails**

Run: `node --test functions/api/chat.test.mjs && E:/tools/flutter/bin/flutter.bat test test/services/openrouter_client_test.dart`
Expected: FAIL because the current code still allows client model override.

**Step 3: Write minimal implementation**

Implement:
- `functions/api/chat.js`: choose `AI_MODEL_NAME` first, then fall back to request-body `model`
- `lib/services/openrouter_client.dart`: stop sending `model` in the JSON payload

**Step 4: Run test to verify it passes**

Run: `node --test functions/api/chat.test.mjs && E:/tools/flutter/bin/flutter.bat test test/services/openrouter_client_test.dart test/features/chat/chat_repository_test.dart`
Expected: PASS for function behavior and Dart client behavior.

**Step 5: Commit**

```bash
git add functions/api/chat.js lib/services/openrouter_client.dart functions/api/chat.test.mjs test/services/openrouter_client_test.dart test/features/chat/chat_repository_test.dart
git commit -m "fix: prefer configured server model"
```

### Task 3: Verify the full app still passes

**Files:**
- Verify only: `functions/api/chat.js`
- Verify only: `lib/services/openrouter_client.dart`
- Verify only: `functions/api/chat.test.mjs`
- Verify only: `test/services/openrouter_client_test.dart`

**Step 1: Run targeted tests**

Run: `node --test functions/api/chat.test.mjs && E:/tools/flutter/bin/flutter.bat test test/services/openrouter_client_test.dart test/features/chat/chat_repository_test.dart`
Expected: PASS.

**Step 2: Run full Flutter suite**

Run: `E:/tools/flutter/bin/flutter.bat test`
Expected: PASS with no regressions.

**Step 3: Review diff**

Ensure the change is limited to model-priority behavior and tests.

**Step 4: Verify git status**

Run: `git status --short`
Expected: only model-priority fix files are changed.

**Step 5: Commit**

```bash
git add functions/api/chat.js lib/services/openrouter_client.dart functions/api/chat.test.mjs test/services/openrouter_client_test.dart test/features/chat/chat_repository_test.dart docs/plans/2026-03-22-server-model-priority-design.md docs/plans/2026-03-22-server-model-priority-implementation.md
git commit -m "fix: enforce server-side model selection"
```
