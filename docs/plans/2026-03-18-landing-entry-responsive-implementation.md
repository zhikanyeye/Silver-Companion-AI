# 银龄智伴首页精简与多端自适应实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 删除首页辅助说明区，并完成首页与登录页在手机、平板、桌面三档下的自适应优化。

**Architecture:** 首页保留 `BrandHero` 作为唯一主视觉区块，去掉 `landing_page.dart` 中独立的辅助说明卡片；首页与登录页统一引入更细的断点策略，按三档设备分别调整最大宽度、内外边距、圆角、字号与间距。测试先行，先让已删除文案与响应式断言失败，再用最小实现让页面和测试回到一致状态。

**Tech Stack:** Flutter, Dart, Material 3, widget tests, `flutter test`

---

### Task 1: 让首页测试先体现“删除辅助说明区”

**Files:**
- Modify: `test/features/landing/landing_page_test.dart`

**Step 1: Write the failing test**

把首页断言从“出现 `安心开始` / `一步完成`”改为“这些辅助文案不再出现”；补充断言确认 `银龄智伴`、`登录`、`注册` 仍然可见。

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart`
Expected: FAIL，因为页面仍在渲染被删除的辅助说明区。

**Step 3: Write minimal implementation**

暂不改实现，先让失败用例成为后续改动的目标基线。

**Step 4: Run test to verify it fails for the right reason**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart`
Expected: FAIL，且失败原因明确指向旧辅助文案仍然存在。

**Step 5: Commit**

```bash
git add test/features/landing/landing_page_test.dart
git commit -m "test: remove landing support panel expectations"
```

### Task 2: 删除首页辅助说明区并改成单核心首屏

**Files:**
- Modify: `lib/features/landing/landing_page.dart`
- Test: `test/features/landing/landing_page_test.dart`

**Step 1: Write the failing test**

沿用 Task 1 的失败状态，确保首页删除辅助说明区是当前唯一需要修复的行为。

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart`
Expected: FAIL，仍能看到旧辅助说明区相关文案。

**Step 3: Write minimal implementation**

删除 `lib/features/landing/landing_page.dart` 中 `_HeroSupportPanel` 及其调用，改为首页只渲染顶部操作区与居中的 `BrandHero`。保留动画和滚动结构，但不再使用左右双栏布局。

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart`
Expected: PASS，首页不再出现被删除文案且主入口仍可正常导航。

**Step 5: Commit**

```bash
git add lib/features/landing/landing_page.dart test/features/landing/landing_page_test.dart
git commit -m "refactor: simplify landing hero layout"
```

### Task 3: 为首页主视觉补齐三档响应式表现

**Files:**
- Modify: `lib/widgets/brand_hero.dart`
- Modify: `lib/features/landing/landing_page.dart`
- Test: `test/features/landing/landing_page_test.dart`

**Step 1: Write the failing test**

在 `test/features/landing/landing_page_test.dart` 增加一组窄屏与宽屏布局回归断言，确认首页在不同尺寸下仍只存在一个主视觉区，并且核心按钮保持可见。

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart`
Expected: FAIL，当前布局只区分两档，窄屏或宽屏断言无法满足新的期望。

**Step 3: Write minimal implementation**

为 `BrandHero` 增加基于宽度的紧凑 / 标准 / 宽屏样式调整，细化卡片内边距、标题字号、chip 和能力卡片间距；同步在 `landing_page.dart` 中调整页面最大宽度与边距策略。

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart`
Expected: PASS，首页在窄屏和宽屏都保留稳定层级且无辅助说明区回归。

**Step 5: Commit**

```bash
git add lib/widgets/brand_hero.dart lib/features/landing/landing_page.dart test/features/landing/landing_page_test.dart
git commit -m "feat: improve landing responsiveness across devices"
```

### Task 4: 为登录页补齐三档响应式回归与实现

**Files:**
- Modify: `test/features/auth/auth_page_test.dart`
- Modify: `lib/features/auth/auth_page.dart`
- Modify: `lib/features/auth/widgets/auth_form.dart`

**Step 1: Write the failing test**

在 `test/features/auth/auth_page_test.dart` 增加窄屏场景用例，断言登录页在较小视口下仍能看到标题、页签、输入项和主按钮；必要时补充宽屏场景用例，约束卡片结构保持单卡片布局。

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/auth/auth_page_test.dart`
Expected: FAIL，当前卡片宽度 / 留白策略无法满足新的响应式断言。

**Step 3: Write minimal implementation**

调整 `lib/features/auth/auth_page.dart` 的滚动留白、卡片最大宽度、卡片内边距与背景装饰比例；如有必要，在 `lib/features/auth/widgets/auth_form.dart` 中细化标题与字段间距，使手机与平板场景更稳定。

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/auth/auth_page_test.dart`
Expected: PASS，登录页在窄屏 / 宽屏下都保留清晰的单卡片入口体验。

**Step 5: Commit**

```bash
git add lib/features/auth/auth_page.dart lib/features/auth/widgets/auth_form.dart test/features/auth/auth_page_test.dart
git commit -m "feat: refine auth entry responsiveness"
```

### Task 5: 做整体验证

**Files:**
- Verify only: `lib/features/landing/landing_page.dart`
- Verify only: `lib/widgets/brand_hero.dart`
- Verify only: `lib/features/auth/auth_page.dart`
- Verify only: `lib/features/auth/widgets/auth_form.dart`
- Verify only: `test/features/landing/landing_page_test.dart`
- Verify only: `test/features/auth/auth_page_test.dart`

**Step 1: Run targeted tests**

Run: `E:/tools/flutter/bin/flutter.bat test test/features/landing/landing_page_test.dart test/features/auth/auth_page_test.dart`
Expected: PASS，首页与登录页的主要回归通过。

**Step 2: Run full test suite**

Run: `E:/tools/flutter/bin/flutter.bat test`
Expected: PASS，确认没有引入跨页面回归。

**Step 3: Review diff**

检查改动是否只覆盖首页 / 登录页自适应与对应测试，没有顺手引入额外视觉重构。

**Step 4: Verify git status**

Run: `git status --short`
Expected: 只包含本任务相关文件。

**Step 5: Commit**

```bash
git add lib/features/landing/landing_page.dart lib/widgets/brand_hero.dart lib/features/auth/auth_page.dart lib/features/auth/widgets/auth_form.dart test/features/landing/landing_page_test.dart test/features/auth/auth_page_test.dart
git commit -m "feat: simplify responsive entry experience"
```
*** Delete File: docs/plans/2026-03-18-landing-entry-responsive-design.md
*** Delete File: docs/plans/2026-03-18-landing-entry-responsive-implementation.md
