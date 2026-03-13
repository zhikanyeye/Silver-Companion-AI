# Community Feed Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the community feed into a warmer, senior-friendly mutual-aid page with pinned notices, recommended/latest switching, and richer post cards that fit the 银龄智伴 product direction.

**Architecture:** Keep the existing Flutter route and page entry points, but replace the current simple list structure with a multi-section feed. Expand local mock data to support notice bars, richer metadata, and lightweight tab switching while preserving the floating publish action and existing demo-safe interactions.

**Tech Stack:** Flutter, Dart, Material 3, existing theme tokens, widget tests.

---

### Task 1: Expand community test expectations and data model

**Files:**
- Modify: `test/widgets/community_feed_test.dart`
- Modify: `lib/features/community/mock_posts.dart`

**Step 1: Write the failing test**

Update `test/widgets/community_feed_test.dart` so it expects:
- a pinned notice area with labels like `社区公告` and `防诈提醒`
- a segmented area with `推荐` and `最新`
- a richer community card including a post title and response status
- the existing `发布互助` action still works

Add or adjust injected test data expectations so custom posts can render with the richer fields.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/community_feed_test.dart`
Expected: FAIL because the current page does not render the new sections or richer card fields.

**Step 3: Write minimal implementation**

Update `lib/features/community/mock_posts.dart` to support:
- author name
- role/identity subtitle
- category tag
- title
- summary
- location
- time
- response status text
- feed bucket such as `recommended` or `latest`

Keep the sample data small and focused on elder-care mutual aid scenarios.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/community_feed_test.dart`
Expected: still FAIL or partially fail until page UI is rebuilt in the next tasks.

**Step 5: Commit**

```bash
git add test/widgets/community_feed_test.dart lib/features/community/mock_posts.dart
git commit -m "test: define redesigned community feed expectations"
```

---

### Task 2: Rebuild the top section with hero and pinned notices

**Files:**
- Modify: `lib/features/community/community_feed_page.dart`
- Test: `test/widgets/community_feed_test.dart`

**Step 1: Write the failing test**

Add exact assertions for:
- hero copy such as `看看邻里间正在发生的帮助与回应`
- notice labels such as `社区公告`, `防诈提醒`, `本周活动`

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/community_feed_test.dart`
Expected: FAIL because the current page only has a simple hero and no pinned notice section.

**Step 3: Write minimal implementation**

In `lib/features/community/community_feed_page.dart`:
- replace the current single hero intro with a branded hero block
- add a pinned notice section under the hero
- use warm cards or list bars instead of forum-style lines

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/community_feed_test.dart`
Expected: hero and notice assertions PASS.

**Step 5: Commit**

```bash
git add lib/features/community/community_feed_page.dart test/widgets/community_feed_test.dart
git commit -m "feat: add community hero and pinned notice section"
```

---

### Task 3: Add recommended/latest switching and richer feed cards

**Files:**
- Modify: `lib/features/community/community_feed_page.dart`
- Modify: `lib/features/community/mock_posts.dart`
- Test: `test/widgets/community_feed_test.dart`

**Step 1: Write the failing test**

Add test coverage for:
- `推荐` and `最新` tabs/segmented controls
- default rendering of recommended posts
- switching to latest and seeing latest-only content
- richer card fields such as title and response status

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/community_feed_test.dart`
Expected: FAIL because there is no switching logic and cards do not yet match the new design.

**Step 3: Write minimal implementation**

In `lib/features/community/community_feed_page.dart`:
- introduce lightweight local state for selected feed bucket
- render a custom segmented toggle for `推荐` and `最新`
- filter the local posts list by bucket
- redesign each post card to show identity subtitle, title, summary, metadata, and response status
- keep actions demo-safe with snackbar placeholders where needed

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/community_feed_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/community/community_feed_page.dart lib/features/community/mock_posts.dart test/widgets/community_feed_test.dart
git commit -m "feat: redesign community feed content flow"
```

---

### Task 4: Verify the redesigned page inside the existing route flow

**Files:**
- Test: `test/widgets/community_feed_test.dart`
- Test: `test/widgets/elderly_home_test.dart`

**Step 1: Write the failing test**

Ensure the route-level test still navigates from the elderly page into the community page and that the publish action still shows `发布互助（演示）`.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/community_feed_test.dart test/widgets/elderly_home_test.dart`
Expected: FAIL if any route flow or CTA behavior regressed.

**Step 3: Write minimal implementation**

Fix only the route-flow or CTA issues needed for the redesigned page to remain reachable.

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/community_feed_test.dart test/widgets/elderly_home_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/widgets/community_feed_test.dart test/widgets/elderly_home_test.dart lib/features/community/community_feed_page.dart
git commit -m "test: preserve community route flow after redesign"
```

---

### Task 5: Final widget verification and demo readiness

**Files:**
- Modify: `docs/demo-script.md`

**Step 1: Write the failing test**

No new unit test required. Review `docs/demo-script.md` and update the community section if it no longer matches the redesigned experience.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/app_boot_test.dart test/widgets/routes_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart`
Expected: PASS or reveal redesign regressions that must be fixed before completion.

**Step 3: Write minimal implementation**

- Update the demo script wording if needed
- Avoid unrelated feature work

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/app_boot_test.dart test/widgets/routes_test.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart test/widgets/community_feed_test.dart test/widgets/settings_entry_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add docs/demo-script.md
git commit -m "docs: refresh community demo walkthrough"
```
