# 银龄智伴落地页认证与角色分流重构 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 重构银龄智伴的 landing / auth / role 入口流程，让未登录用户先看到品牌落地页，认证后再选择角色进入现有老人端或子女端页面。

**Architecture:** 保留现有老人端和子女端业务路由，只重做前置入口链路：`landing -> auth -> role select -> existing pages`。路由集中放在 `lib/routes.dart`，应用装配放在 `lib/app.dart`，页面与组件拆到 `lib/features/` 下，降低对现有页面的影响。

**Tech Stack:** Flutter, Dart, Material 3, flutter_test

---

### Task 1: 重建入口路由骨架

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/routes.dart`
- Modify: `test/widget_test.dart`
- Modify: `test/widgets/app_boot_test.dart`
- Create: `test/features/navigation/entry_flow_routes_test.dart`

**Step 1: Write the failing test**
- 先补测试，验证 App 默认进入 landing。
- 验证 landing 可进入 auth。
- 验证 auth 成功后可进入 role select。
- 验证 role select 可继续进入现有老人页和子女页。

**Step 2: Run test to verify it fails**
Run:
```bash
flutter test test/widget_test.dart test/widgets/app_boot_test.dart test/features/navigation/entry_flow_routes_test.dart
```
Expected: FAIL，因为当前默认启动页和路由结构仍是旧流程。

**Step 3: Write minimal implementation**
- 在 `lib/routes.dart` 中补充 landing、auth、role select、elderly、child 的路由常量。
- 在 `lib/app.dart` 中把初始路由切到 landing。
- 保留现有老人端、子女端页面对应路由，先只打通跳转骨架。

**Step 4: Run test to verify it passes**
Run:
```bash
flutter test test/widget_test.dart test/widgets/app_boot_test.dart test/features/navigation/entry_flow_routes_test.dart
```
Expected: PASS。

**Step 5: Commit**
```bash
git add lib/app.dart lib/routes.dart test/widget_test.dart test/widgets/app_boot_test.dart test/features/navigation/entry_flow_routes_test.dart
git commit -m "refactor: route app entry through landing flow"
```

### Task 2: 实现仅展示品牌与登录注册入口的 landing 页

**Files:**
- Modify: `lib/widgets/brand_hero.dart`
- Modify or Rework: `lib/widgets/login_overlay.dart`
- Create: `lib/features/landing/landing_page.dart`
- Create: `test/features/landing/landing_page_test.dart`

**Step 1: Write the failing test**
- 补 landing 页测试，验证页面展示品牌 hero。
- 验证右上角只有 `登录`、`注册`。
- 验证页面不出现输入框，不出现 `我是老人` / `我是子女`。
- 验证点击 `登录` 或 `注册` 会进入 auth 页。

**Step 2: Run test to verify it fails**
Run:
```bash
flutter test test/features/landing/landing_page_test.dart
```
Expected: FAIL，因为 `LandingPage` 还不存在。

**Step 3: Write minimal implementation**
- 新建 `lib/features/landing/landing_page.dart`。
- 复用并整理 `lib/widgets/brand_hero.dart`。
- 将 `lib/widgets/login_overlay.dart` 从 landing 上移除或收敛为可复用外壳。
- landing 仅保留品牌视觉和右上角 `登录` / `注册` 按钮，并带上初始 tab 参数跳转到 auth。

**Step 4: Run test to verify it passes**
Run:
```bash
flutter test test/features/landing/landing_page_test.dart
```
Expected: PASS。

**Step 5: Commit**
```bash
git add lib/widgets/brand_hero.dart lib/widgets/login_overlay.dart lib/features/landing/landing_page.dart test/features/landing/landing_page_test.dart
git commit -m "feat: add hero-first landing page entry"
```

### Task 3: 实现登录/注册共用的 auth 页

**Files:**
- Create: `lib/features/auth/auth_page.dart`
- Create: `lib/features/auth/widgets/auth_tabs.dart`
- Create: `lib/features/auth/widgets/auth_form.dart`
- Modify: `lib/app.dart`
- Modify: `lib/routes.dart`
- Create: `test/features/auth/auth_page_test.dart`

**Step 1: Write the failing test**
- 补 auth 页测试，验证同一页面上有 `登录` / `注册` 两个 tab。
- 验证切换 tab 后显示对应表单状态。
- 验证输入最小演示字段后提交即可成功。
- 验证成功后跳转到 role select。

**Step 2: Run test to verify it fails**
Run:
```bash
flutter test test/features/auth/auth_page_test.dart
```
Expected: FAIL，因为共享 auth 页和 tab 结构尚未实现。

**Step 3: Write minimal implementation**
- 新建 `AuthPage`。
- 在一个页面里放登录/注册两个 tab。
- 表单只做最弱校验，例如非空即可。
- 提交成功后直接导航到 role select。
- 支持从 landing 传入初始 tab，确保 `登录` 和 `注册` 按钮行为不同。

**Step 4: Run test to verify it passes**
Run:
```bash
flutter test test/features/auth/auth_page_test.dart
```
Expected: PASS。

**Step 5: Commit**
```bash
git add lib/features/auth/auth_page.dart lib/features/auth/widgets/auth_tabs.dart lib/features/auth/widgets/auth_form.dart lib/app.dart lib/routes.dart test/features/auth/auth_page_test.dart
git commit -m "feat: add shared tabbed auth surface"
```

### Task 4: 实现认证后的角色选择页

**Files:**
- Create: `lib/features/role/role_select_page.dart`
- Create: `lib/features/role/widgets/role_option_card.dart`
- Modify: `lib/app.dart`
- Modify: `lib/routes.dart`
- Create: `test/features/role/role_select_page_test.dart`

**Step 1: Write the failing test**
- 补 role 页测试，验证页面展示 `我是老人` 和 `我是子女` 两个选项。
- 验证点击老人选项进入现有 elderly 页面。
- 验证点击子女选项进入现有 child 页面。
- 验证 role 页只应出现在 auth 成功之后。

**Step 2: Run test to verify it fails**
Run:
```bash
flutter test test/features/role/role_select_page_test.dart
```
Expected: FAIL，因为角色选择页和对应导航尚未存在。

**Step 3: Write minimal implementation**
- 新建 `RoleSelectPage`。
- 新建 `RoleOptionCard` 作为两个选项的通用卡片。
- 点击 `我是老人` 跳到现有老人页路由。
- 点击 `我是子女` 跳到现有子女页路由。

**Step 4: Run test to verify it passes**
Run:
```bash
flutter test test/features/role/role_select_page_test.dart
```
Expected: PASS。

**Step 5: Commit**
```bash
git add lib/features/role/role_select_page.dart lib/features/role/widgets/role_option_card.dart lib/app.dart lib/routes.dart test/features/role/role_select_page_test.dart
git commit -m "feat: add post-auth role selection routing"
```

### Task 5: 保持现有老人端/子女端路由可直接使用

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/routes.dart`
- Create: `test/features/navigation/legacy_route_compat_test.dart`

**Step 1: Write the failing test**
- 补兼容性测试，验证旧 elderly 路由仍可直接打开。
- 验证旧 child 路由仍可直接打开。
- 验证新增 landing/auth/role 流程不会破坏已有跳转入口。

**Step 2: Run test to verify it fails**
Run:
```bash
flutter test test/features/navigation/legacy_route_compat_test.dart
```
Expected: FAIL，如果新路由重构过程中改坏了映射。

**Step 3: Write minimal implementation**
- 在 `lib/routes.dart` 中保留旧路由名。
- 如有必要，给新旧路由都提供别名映射。
- 兼容逻辑集中在路由层处理。

**Step 4: Run test to verify it passes**
Run:
```bash
flutter test test/features/navigation/legacy_route_compat_test.dart
```
Expected: PASS。

**Step 5: Commit**
```bash
git add lib/app.dart lib/routes.dart test/features/navigation/legacy_route_compat_test.dart
git commit -m "fix: preserve legacy route compatibility"
```

### Task 6: 完成 landing/auth/role 三页美化与动效，并用测试锁定

**Files:**
- Modify: `lib/features/landing/landing_page.dart`
- Modify: `lib/features/auth/auth_page.dart`
- Modify: `lib/features/role/role_select_page.dart`
- Modify: `lib/widgets/brand_hero.dart`
- Create: `test/features/ui/entry_flow_visual_test.dart`

**Step 1: Write the failing test**
- 补 UI 回归测试，验证 landing、auth、role 三页在手机尺寸与较宽尺寸下都不会 overflow。
- 验证页面关键元素在动画结束后仍可见。
- 验证 `pumpAndSettle` 后 hero、auth 卡片、role 卡片都存在。

**Step 2: Run test to verify it fails**
Run:
```bash
flutter test test/features/ui/entry_flow_visual_test.dart
```
Expected: FAIL，因为当前页面还没有最终布局与动效整理。

**Step 3: Write minimal implementation**
- 为 landing / auth / role 页面补充轻量入场动画，如 `AnimatedOpacity`、`AnimatedSlide`、`TweenAnimationBuilder`。
- 优化移动端与宽屏下的间距、对齐、层次。
- 保持动画短且可测试，避免不稳定异步行为。

**Step 4: Run test to verify it passes**
Run:
```bash
flutter test test/features/ui/entry_flow_visual_test.dart
```
Expected: PASS。

**Step 5: Commit**
```bash
git add lib/features/landing/landing_page.dart lib/features/auth/auth_page.dart lib/features/role/role_select_page.dart lib/widgets/brand_hero.dart test/features/ui/entry_flow_visual_test.dart
git commit -m "feat: polish entry flow layouts and motion"
```
