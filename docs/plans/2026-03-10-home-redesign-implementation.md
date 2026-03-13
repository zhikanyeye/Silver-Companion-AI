# 银龄智伴首页重设计 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a warmer, brand-aligned home experience for 银龄智伴, rename roles to 老人端/子女端/平台端, and align the visual language for Web while remaining suitable for future App and mini-program products.

**Architecture:** Keep the existing Flutter app structure and replace the current plain role list with a branded, card-based landing page. Update route labels and key page headers, add branding assets, and preserve current feature flows for elderly, child/parent, community, settings, and chat with minimal functional churn.

**Tech Stack:** Flutter, Dart, Material 3, existing app routes/theme, widget tests.

---

### Task 1: Rework home selector information architecture

**Files:**
- Modify: `lib/app.dart`
- Test: `test/widgets/app_boot_test.dart`
- Test: `test/widgets/settings_entry_test.dart`

**Step 1: Write the failing test**

Update `test/widgets/app_boot_test.dart` so it expects:
- page title `银龄智伴`
- role cards/entries: `老人端`, `子女端`, `平台端`
- settings is present as a secondary entry, not a main role label

Update `test/widgets/settings_entry_test.dart` if needed to still navigate through the new settings affordance.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/app_boot_test.dart test/widgets/settings_entry_test.dart`
Expected: FAIL because current UI still shows `为谁服务？/长者/儿童`.

**Step 3: Write minimal implementation**

In `lib/app.dart`:
- Replace the plain list layout with branded sections
- Add top brand block with title/subtitle
- Add three role cards or prominent entries: `老人端`, `子女端`, `平台端`
- Keep settings accessible in a secondary position (top-right action or secondary list item)

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/app_boot_test.dart test/widgets/settings_entry_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/app.dart test/widgets/app_boot_test.dart test/widgets/settings_entry_test.dart
git commit -m "feat: redesign home selector layout"
```

---

### Task 2: Update route naming and role labels

**Files:**
- Modify: `lib/routes.dart`
- Modify: `lib/features/elderly/elderly_home_page.dart`
- Modify: `lib/features/child/child_home_page.dart`
- Test: `test/widgets/routes_test.dart`
- Test: `test/widgets/child_home_test.dart`
- Test: `test/widgets/elderly_home_test.dart`

**Step 1: Write the failing test**

Adjust tests to expect the renamed role language and updated page titles:
- `老人端`
- `子女端`
- `平台端` (can be placeholder page)

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/routes_test.dart test/widgets/child_home_test.dart test/widgets/elderly_home_test.dart`
Expected: FAIL because current route labels/titles still reflect old wording.

**Step 3: Write minimal implementation**

- Update route destination titles and labels
- Add a placeholder platform page route if needed
- Ensure existing chat/community/settings flows remain reachable

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/routes_test.dart test/widgets/child_home_test.dart test/widgets/elderly_home_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/routes.dart lib/features/elderly/elderly_home_page.dart lib/features/child/child_home_page.dart test/widgets/routes_test.dart test/widgets/child_home_test.dart test/widgets/elderly_home_test.dart
git commit -m "feat: align role naming with product design"
```

---

### Task 3: Introduce branded visual blocks and reusable style tokens

**Files:**
- Modify: `lib/theme/app_theme.dart`
- Modify: `lib/app.dart`
- Create: `lib/widgets/brand_hero.dart`
- Create: `lib/widgets/role_entry_card.dart`
- Test: `test/widgets/app_boot_test.dart`

**Step 1: Write the failing test**

Extend `test/widgets/app_boot_test.dart` to assert presence of:
- brand subtitle
- capability section heading
- role cards with icons/buttons

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/app_boot_test.dart`
Expected: FAIL because these branded sections/components do not exist yet.

**Step 3: Write minimal implementation**

- Add warmer palette tokens in `app_theme.dart`
- Add reusable `BrandHero` and `RoleEntryCard`
- Use card-based mobile-friendly layout in `lib/app.dart`

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/app_boot_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/theme/app_theme.dart lib/app.dart lib/widgets/brand_hero.dart lib/widgets/role_entry_card.dart test/widgets/app_boot_test.dart
git commit -m "feat: add branded home visual system"
```

---

### Task 4: Add logo assets and wire them into the home experience

**Files:**
- Create: `web/assets/branding/yinling-logo-mark.svg`
- Create: `web/assets/branding/yinling-logo-lockup-zh-en.svg`
- Create: `web/assets/branding/LOGO_USAGE.md`
- Modify: `README.md`
- Modify: `web/index.html`

**Step 1: Write the failing test**

No automated SVG rendering test required. Instead create a verification checklist note in `LOGO_USAGE.md` before integrating references.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/app_boot_test.dart`
Expected: PASS still; use this task for asset integration verification rather than new failing unit tests.

**Step 3: Write minimal implementation**

- Add the generated SVG assets
- Reference the lockup/logo in documentation and home page usage notes
- Keep Web metadata consistent with brand

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/app_boot_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add web/assets/branding README.md web/index.html
git commit -m "feat: add brand logo assets"
```

---

### Task 5: Refresh elderly and child page visual language

**Files:**
- Modify: `lib/features/elderly/elderly_home_page.dart`
- Modify: `lib/features/child/child_home_page.dart`
- Modify: `lib/features/community/community_feed_page.dart`
- Test: `test/widgets/elderly_home_test.dart`
- Test: `test/widgets/child_home_test.dart`
- Test: `test/widgets/community_feed_test.dart`

**Step 1: Write the failing test**

Update tests to expect refreshed section headings or supportive copy aligned with the new design language while preserving existing functional checks.

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart test/widgets/community_feed_test.dart`
Expected: FAIL because current copy/layout is not yet updated.

**Step 3: Write minimal implementation**

- Add section headers, warmer cards, and softer visual hierarchy
- Preserve tap paths and current feature behavior
- Keep layout mobile-first for App/mini-program aesthetic reuse

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart test/widgets/community_feed_test.dart`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/elderly/elderly_home_page.dart lib/features/child/child_home_page.dart lib/features/community/community_feed_page.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart test/widgets/community_feed_test.dart
git commit -m "feat: unify product page visual language"
```

---

### Task 6: Full verification and deployment refresh

**Files:**
- Modify: `docs/demo-script.md`

**Step 1: Write the failing test**

No new unit test required; instead revise `docs/demo-script.md` to match the renamed roles and redesigned home.

**Step 2: Run test to verify it fails**

Run: `flutter test`
Expected: PASS or identify regressions from the redesign.

**Step 3: Write minimal implementation**

- Update `docs/demo-script.md` to the new walkthrough
- Rebuild web output after all tests pass

**Step 4: Run test to verify it passes**

Run: `flutter test && flutter build web --release --no-wasm-dry-run`
Expected: PASS and build output generated under `build/web`.

**Step 5: Commit**

```bash
git add docs/demo-script.md
git commit -m "docs: refresh demo walkthrough for redesigned home"
```
