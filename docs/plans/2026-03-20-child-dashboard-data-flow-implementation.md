# Child Dashboard Data Flow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Upgrade the child dashboard from static constants to a structured async-loaded data flow with local service, loading/error states, and refresh behavior.

**Architecture:** Introduce a `ChildDashboardData` model and a `ChildDashboardService` that currently serves local mock data asynchronously. Refactor `ChildHomePage` to load through the service, display loading/error/loaded states, and support refresh without changing the visual dashboard hierarchy more than necessary.

**Tech Stack:** Flutter, Dart, Material 3, widget tests, unit tests, `flutter test`

---

### Task 1: Make tests express async-loaded child dashboard behavior

**Files:**
- Modify: `test/widgets/child_home_test.dart`

**Step 1: Write the failing test**

Change the child dashboard tests so they no longer assume synchronous mock rendering. Add expectations for a loading state first, then loaded dashboard content after the async service completes.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart`
Expected: FAIL because the current page renders immediate static content and has no loading flow.

**Step 3: Write minimal implementation**

Do not change production code yet. Let the new test define the target async behavior.

**Step 4: Run test to verify it fails for the right reason**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart`
Expected: FAIL because loading/error/refresh behavior is missing, not because of test setup issues.

**Step 5: Commit**

```bash
git add test/widgets/child_home_test.dart
git commit -m "test: define async child dashboard behavior"
```

### Task 2: Introduce child dashboard models and local service

**Files:**
- Modify: `lib/features/child/mock_family_data.dart`
- Create: `lib/features/child/child_dashboard_service.dart`
- Create: `test/features/child/child_dashboard_service_test.dart`

**Step 1: Write the failing test**

Add a service test that expects `ChildDashboardService.loadDashboard()` to return one structured dashboard object with overview metrics, status cards, and alerts.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/child/child_dashboard_service_test.dart`
Expected: FAIL because the service and structured model do not exist yet.

**Step 3: Write minimal implementation**

Implement:
- structured dashboard model types in `mock_family_data.dart` or adjacent child model file
- `ChildDashboardService` with `Future<ChildDashboardData> loadDashboard()`
- local mock-backed implementation with a small async delay

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/child/child_dashboard_service_test.dart`
Expected: PASS with one coherent dashboard payload returned.

**Step 5: Commit**

```bash
git add lib/features/child/mock_family_data.dart lib/features/child/child_dashboard_service.dart test/features/child/child_dashboard_service_test.dart
git commit -m "feat: add child dashboard service layer"
```

### Task 3: Refactor child home into async-loaded dashboard page

**Files:**
- Modify: `lib/features/child/child_home_page.dart`
- Modify: `test/widgets/child_home_test.dart`

**Step 1: Write the failing test**

Use the failing widget tests from Task 1 as the target. Add expectations for visible loading UI, then loaded content, and preserve stacked/split responsive layout checks.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart`
Expected: FAIL because the page still renders synchronously from constants.

**Step 3: Write minimal implementation**

Refactor `ChildHomePage` to:
- load dashboard data through `ChildDashboardService`
- render loading state first
- render loaded dashboard after async completion
- keep current telecom-style dashboard sections and split-layout behavior

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart`
Expected: PASS with loading and loaded states both covered.

**Step 5: Commit**

```bash
git add lib/features/child/child_home_page.dart test/widgets/child_home_test.dart
git commit -m "feat: load child dashboard asynchronously"
```

### Task 4: Add error and refresh behavior

**Files:**
- Modify: `lib/features/child/child_home_page.dart`
- Create: `test/features/child/child_home_page_state_test.dart`

**Step 1: Write the failing test**

Create widget tests for:
- service failure -> visible error message + retry button
- refresh gesture -> reload flow triggered and content stays coherent

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/child/child_home_page_state_test.dart`
Expected: FAIL because no error/retry or refresh state is implemented yet.

**Step 3: Write minimal implementation**

Implement:
- retry button in error state
- `RefreshIndicator` on loaded state
- service injection path so tests can provide fake success/failure services

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/child/child_home_page_state_test.dart test/widgets/child_home_test.dart`
Expected: PASS for both state-behavior and layout coverage.

**Step 5: Commit**

```bash
git add lib/features/child/child_home_page.dart test/features/child/child_home_page_state_test.dart test/widgets/child_home_test.dart
git commit -m "feat: add child dashboard refresh and error states"
```

### Task 5: Verify the complete change set

**Files:**
- Verify only: `lib/features/child/child_home_page.dart`
- Verify only: `lib/features/child/mock_family_data.dart`
- Verify only: `lib/features/child/child_dashboard_service.dart`
- Verify only: `test/widgets/child_home_test.dart`
- Verify only: `test/features/child/child_dashboard_service_test.dart`
- Verify only: `test/features/child/child_home_page_state_test.dart`

**Step 1: Run targeted tests**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart test/features/child/child_dashboard_service_test.dart test/features/child/child_home_page_state_test.dart`
Expected: PASS for the new child dashboard data-flow coverage.

**Step 2: Run full test suite**

Run: `E:/tools/flutter/bin/flutter.bat test`
Expected: PASS with no regressions across the app.

**Step 3: Review diff**

Ensure the diff is limited to child dashboard data flow, tests, and docs. Do not let unrelated refactors slip in.

**Step 4: Verify git status**

Run: `git status --short`
Expected: only intended child dashboard data-flow files are modified.

**Step 5: Commit**

```bash
git add lib/features/child/child_home_page.dart lib/features/child/mock_family_data.dart lib/features/child/child_dashboard_service.dart test/widgets/child_home_test.dart test/features/child/child_dashboard_service_test.dart test/features/child/child_home_page_state_test.dart docs/plans/2026-03-20-child-dashboard-data-flow-design.md docs/plans/2026-03-20-child-dashboard-data-flow-implementation.md
git commit -m "feat: add child dashboard data flow"
```
