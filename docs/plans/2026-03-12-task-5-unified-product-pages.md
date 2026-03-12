# Task 5 Unified Product Pages Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refresh the elderly, child, and community pages into one warm, brand-consistent mobile hierarchy while preserving all existing navigation and feedback behavior.

**Architecture:** Update the three page widgets in place with a shared visual rhythm: welcoming hero copy, supportive section headers, and stacked warm cards sized for mobile. Drive the change through widget tests first so the new copy and preserved chat/community/FAB flows are locked before implementation.

**Tech Stack:** Flutter, Material widgets, flutter_test

---

### Task 1: Lock the redesigned copy in widget tests

**Files:**
- Modify: `test/widgets/elderly_home_test.dart`
- Modify: `test/widgets/child_home_test.dart`
- Modify: `test/widgets/community_feed_test.dart`

**Step 1: Write the failing tests**

Add expectations for these visible strings while keeping existing flow assertions:

```dart
expect(find.text('今天也有人陪你慢慢聊'), findsOneWidget);
expect(find.text('家人近况一眼安心'), findsOneWidget);
expect(find.text('邻里互助，温暖就在身边'), findsOneWidget);
```

**Step 2: Run test to verify it fails**

Run: `E:\tools\flutter\bin\flutter.bat test test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart test/widgets/community_feed_test.dart`

Expected: FAIL because the new copy does not exist yet.

### Task 2: Implement minimal elderly, child, and community UI updates

**Files:**
- Modify: `lib/features/elderly/elderly_home_page.dart`
- Modify: `lib/features/child/child_home_page.dart`
- Modify: `lib/features/community/community_feed_page.dart`

**Step 1: Write the minimal implementation**

Update each page to include the tested headline and a warmer card hierarchy while preserving:

```dart
Navigator.of(context).pushNamed(chatRoute)
Navigator.of(context).pushNamed(communityRoute)
ScaffoldMessenger.of(context).showSnackBar(...)
FloatingActionButton.extended(...)
```

**Step 2: Run test to verify it passes**

Run: `E:\tools\flutter\bin\flutter.bat test test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart test/widgets/community_feed_test.dart`

Expected: PASS for all three test files.

### Task 3: Commit the verified redesign

**Files:**
- Commit: `docs/plans/2026-03-12-task-5-unified-product-pages.md`
- Commit: `lib/features/elderly/elderly_home_page.dart`
- Commit: `lib/features/child/child_home_page.dart`
- Commit: `lib/features/community/community_feed_page.dart`
- Commit: `test/widgets/elderly_home_test.dart`
- Commit: `test/widgets/child_home_test.dart`
- Commit: `test/widgets/community_feed_test.dart`

**Step 1: Stage the changed files**

```bash
git add docs/plans/2026-03-12-task-5-unified-product-pages.md lib/features/elderly/elderly_home_page.dart lib/features/child/child_home_page.dart lib/features/community/community_feed_page.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart test/widgets/community_feed_test.dart
```

**Step 2: Create the commit**

```bash
git commit -m "feat: unify product page visual language"
```

**Step 3: Verify commit status**

Run: `git status --short`

Expected: No staged or modified versions of the files included in the commit.
