# Global UI Unification Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Unify the app's major pages under one shared design system while preserving a warm brand feel for entry pages and a blue service feel for functional pages.

**Architecture:** First centralize visual tokens and shared component rules in `app_theme.dart`, then refactor feature pages to consume that system instead of ad-hoc per-page styling. Treat entry pages and feature pages as two visual modes on top of the same token base, and verify that layout and navigation behavior remain stable through widget tests.

**Tech Stack:** Flutter, Dart, Material 3, widget tests, `flutter test`

---

### Task 1: Define failing expectations for unified visual structure on key pages

**Files:**
- Modify: `test/features/landing/landing_page_test.dart`
- Modify: `test/widgets/community_feed_test.dart`
- Modify: `test/widgets/settings_entry_test.dart`

**Step 1: Write the failing test**

Add or update structural expectations so entry pages and feature pages expose more consistent shell-level UI markers (section headers, service cards, primary actions, shared spacing structure).

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart`
Expected: FAIL because the current pages still use mixed styling patterns and inconsistent visual shells.

**Step 3: Write minimal implementation**

Do not change production code yet. Let the tests define the desired structural consistency.

**Step 4: Run test to verify it fails for the right reason**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart`
Expected: FAIL because the shared visual system is not implemented yet.

**Step 5: Commit**

```bash
git add test/features/landing/landing_page_test.dart test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart
git commit -m "test: define unified page shell expectations"
```

### Task 2: Centralize global visual tokens and shared theme rules

**Files:**
- Modify: `lib/theme/app_theme.dart`
- Test: `test/features/landing/landing_page_test.dart`

**Step 1: Write the failing test**

Use the failing shell-structure tests from Task 1 as the first signal that pages still have mismatched theme application.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart`
Expected: FAIL while pages still diverge in shared token usage.

**Step 3: Write minimal implementation**

Refactor `lib/theme/app_theme.dart` to define:
- warm brand tokens
- blue service tokens
- shared border / surface / status colors
- unified card, text, and button baselines

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart`
Expected: PASS or move closer to the new shared visual contract without breaking page behavior.

**Step 5: Commit**

```bash
git add lib/theme/app_theme.dart test/features/landing/landing_page_test.dart
git commit -m "feat: centralize shared visual design tokens"
```

### Task 3: Unify feature pages under the service-page visual system

**Files:**
- Modify: `lib/features/chat/chat_page.dart`
- Modify: `lib/features/community/community_feed_page.dart`
- Modify: `lib/features/settings/settings_page.dart`
- Test: `test/widgets/community_feed_test.dart`
- Test: `test/widgets/settings_entry_test.dart`

**Step 1: Write the failing test**

Tighten tests so community/settings pages still expose their key content after the service-style shell, spacing, and card adjustments.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart`
Expected: FAIL because the pages have not yet been fully restyled to the shared service-page language.

**Step 3: Write minimal implementation**

Refactor:
- `chat_page.dart` into the shared service-page shell and state-strip language
- `community_feed_page.dart` into the same card/border/hero system
- `settings_page.dart` into the same panel layout and spacing rules

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart`
Expected: PASS with unchanged key interactions.

**Step 5: Commit**

```bash
git add lib/features/chat/chat_page.dart lib/features/community/community_feed_page.dart lib/features/settings/settings_page.dart test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart
git commit -m "feat: unify service page styling"
```

### Task 4: Reconcile entry pages with the unified brand-page system

**Files:**
- Modify: `lib/features/landing/landing_page.dart`
- Modify: `lib/features/auth/auth_page.dart`
- Modify: `lib/features/role/role_select_page.dart`
- Modify: `lib/widgets/brand_hero.dart`
- Test: `test/features/landing/landing_page_test.dart`
- Test: `test/features/auth/auth_page_test.dart`
- Test: `test/features/role/role_select_page_test.dart`

**Step 1: Write the failing test**

Add or tighten assertions so the entry flow keeps its warm-brand identity while matching the same spacing, card, and component rhythm as feature pages.

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart test/features/auth/auth_page_test.dart test/features/role/role_select_page_test.dart`
Expected: FAIL because the pages still use pre-unification styling differences.

**Step 3: Write minimal implementation**

Refactor entry pages to consume the same shared tokens and spacing rules while preserving the warm-brand visual mode.

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart test/features/auth/auth_page_test.dart test/features/role/role_select_page_test.dart`
Expected: PASS with preserved navigation and updated styling rhythm.

**Step 5: Commit**

```bash
git add lib/features/landing/landing_page.dart lib/features/auth/auth_page.dart lib/features/role/role_select_page.dart lib/widgets/brand_hero.dart test/features/landing/landing_page_test.dart test/features/auth/auth_page_test.dart test/features/role/role_select_page_test.dart
git commit -m "feat: unify brand page styling"
```

### Task 5: Verify the unified system across the app

**Files:**
- Verify only: `lib/theme/app_theme.dart`
- Verify only: `lib/features/chat/chat_page.dart`
- Verify only: `lib/features/community/community_feed_page.dart`
- Verify only: `lib/features/settings/settings_page.dart`
- Verify only: `lib/features/landing/landing_page.dart`
- Verify only: `lib/features/auth/auth_page.dart`
- Verify only: `lib/features/role/role_select_page.dart`
- Verify only: `lib/widgets/brand_hero.dart`

**Step 1: Run targeted tests**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart test/features/auth/auth_page_test.dart test/features/role/role_select_page_test.dart test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart`
Expected: PASS for key entry and feature-page regressions.

**Step 2: Run full test suite**

Run: `E:/tools/flutter/bin/flutter.bat test`
Expected: PASS with no app-wide regressions.

**Step 3: Review diff**

Ensure the diff stays focused on visual-system unification and does not introduce unrelated business logic changes.

**Step 4: Verify git status**

Run: `git status --short`
Expected: only UI-unification files are changed.

**Step 5: Commit**

```bash
git add lib/theme/app_theme.dart lib/features/chat/chat_page.dart lib/features/community/community_feed_page.dart lib/features/settings/settings_page.dart lib/features/landing/landing_page.dart lib/features/auth/auth_page.dart lib/features/role/role_select_page.dart lib/widgets/brand_hero.dart test/features/landing/landing_page_test.dart test/features/auth/auth_page_test.dart test/features/role/role_select_page_test.dart test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart docs/plans/2026-03-21-global-ui-unification-design.md docs/plans/2026-03-21-global-ui-unification-implementation.md
git commit -m "feat: unify app-wide visual design system"
```
