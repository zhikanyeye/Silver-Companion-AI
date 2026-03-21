# Elderly Service Closure Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Close the elderly home's remaining placeholder service entries by routing `AI陪伴` to chat, adding a real help bottom sheet, and creating an activities page with local structured data.

**Architecture:** Keep the telecom-style elderly home layout intact and only replace placeholder actions with real user flows. Store help contacts and activities in a dedicated elderly mock-data file, add a new activities route/page, and cover each new flow with widget tests before implementation.

**Tech Stack:** Flutter, Dart, Material 3, widget tests, `flutter test`

---

### Task 1: Make elderly home tests express the new closed-loop actions

**Files:**
- Modify: `test/widgets/elderly_home_test.dart`
- Modify: `test/widgets/routes_test.dart`

**Step 1: Write the failing test**

Replace placeholder expectations so `AI陪伴` must navigate to chat, `一键求助` must open a help bottom sheet, and `活动` must navigate to an activities page.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart test/widgets/routes_test.dart`
Expected: FAIL because the elderly page still shows placeholder feedback for these entries.

**Step 3: Write minimal implementation**

Do not change production code yet. Let the failing tests define the target behavior.

**Step 4: Run test to verify it fails for the right reason**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart test/widgets/routes_test.dart`
Expected: FAIL with missing route / missing sheet / wrong action behavior, not test setup errors.

**Step 5: Commit**

```bash
git add test/widgets/elderly_home_test.dart test/widgets/routes_test.dart
git commit -m "test: define elderly service closure behavior"
```

### Task 2: Route `AI陪伴` to chat and add the help bottom sheet

**Files:**
- Modify: `lib/features/elderly/elderly_home_page.dart`
- Create: `lib/features/elderly/mock_service_data.dart`
- Test: `test/widgets/elderly_home_test.dart`

**Step 1: Write the failing test**

Use the failing tests from Task 1 as the target for chat routing and help-sheet behavior.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart`
Expected: FAIL because `AI陪伴` still shows a snackbar and no help sheet exists.

**Step 3: Write minimal implementation**

Implement these changes:
- Change the `AI陪伴` card tap in `lib/features/elderly/elderly_home_page.dart` to `Navigator.of(context).pushNamed(chatRoute)`
- Add `showModalBottomSheet` for `一键求助`
- Create `lib/features/elderly/mock_service_data.dart` with structured contact data for family, community station, and platform service
- Render bottom-sheet cards from that data and add a copy-number action with user feedback

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart`
Expected: PASS for chat routing and help-sheet visibility / action coverage.

**Step 5: Commit**

```bash
git add lib/features/elderly/elderly_home_page.dart lib/features/elderly/mock_service_data.dart test/widgets/elderly_home_test.dart
git commit -m "feat: close elderly chat and help actions"
```

### Task 3: Add the elderly activities route, page, and local activity data

**Files:**
- Modify: `lib/routes.dart`
- Create: `lib/features/elderly/elderly_activities_page.dart`
- Modify: `lib/features/elderly/mock_service_data.dart`
- Test: `test/widgets/elderly_home_test.dart`
- Test: `test/widgets/routes_test.dart`

**Step 1: Write the failing test**

Add expectations that tapping `活动` opens the elderly activities page and that the page shows both `今日推荐` and `本周活动` sections.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart test/widgets/routes_test.dart`
Expected: FAIL because no activities route/page exists yet.

**Step 3: Write minimal implementation**

Implement these changes:
- Add `elderlyActivitiesRoute` in `lib/routes.dart`
- Create `lib/features/elderly/elderly_activities_page.dart`
- Extend `lib/features/elderly/mock_service_data.dart` with grouped activities data
- Change the elderly home `活动` card to navigate to the new route

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart test/widgets/routes_test.dart`
Expected: PASS with route navigation and activity content visible.

**Step 5: Commit**

```bash
git add lib/routes.dart lib/features/elderly/elderly_activities_page.dart lib/features/elderly/mock_service_data.dart test/widgets/elderly_home_test.dart test/widgets/routes_test.dart
git commit -m "feat: add elderly activities flow"
```

### Task 4: Add focused activities-page coverage and verify the full suite

**Files:**
- Create: `test/features/elderly/elderly_activities_page_test.dart`
- Verify only: `lib/features/elderly/elderly_home_page.dart`
- Verify only: `lib/features/elderly/elderly_activities_page.dart`
- Verify only: `lib/features/elderly/mock_service_data.dart`
- Verify only: `lib/routes.dart`
- Verify only: `test/widgets/elderly_home_test.dart`
- Verify only: `test/widgets/routes_test.dart`

**Step 1: Write the failing test**

Create a dedicated activities-page widget test that asserts the page shows grouped sections, visible activities, and the top explanatory block.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/elderly/elderly_activities_page_test.dart`
Expected: FAIL until the new page structure fully matches the intended grouped layout.

**Step 3: Write minimal implementation**

Adjust the activities page only as needed to satisfy the new dedicated test. Do not expand scope into registration flows.

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/elderly/elderly_activities_page_test.dart test/widgets/elderly_home_test.dart test/widgets/routes_test.dart && E:/tools/flutter/bin/flutter.bat test`
Expected: PASS for targeted tests and then PASS for the full suite.

**Step 5: Commit**

```bash
git add lib/features/elderly/elderly_home_page.dart lib/features/elderly/elderly_activities_page.dart lib/features/elderly/mock_service_data.dart lib/routes.dart test/features/elderly/elderly_activities_page_test.dart test/widgets/elderly_home_test.dart test/widgets/routes_test.dart docs/plans/2026-03-20-elderly-service-closure-design.md docs/plans/2026-03-20-elderly-service-closure-implementation.md
git commit -m "feat: close elderly service entry flows"
```
