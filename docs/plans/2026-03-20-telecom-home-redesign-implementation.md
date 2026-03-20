# 银龄智伴老人端与子女端电信风重设计实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将老人端重构为电信服务大厅式首页，将子女端重构为更稳重的家庭关怀看板，并完成多端自适应与测试回归。

**Architecture:** 老人端优先重排服务入口和欢迎区，形成操作优先的电信式首页；子女端重排总览、状态和提醒，形成信息优先的照护看板。两页都保持现有路由和功能行为，只重构信息层级、视觉语言和响应式布局，并通过 widget tests 锁定不同视口下的稳定表现。

**Tech Stack:** Flutter, Dart, Material 3, widget tests, `flutter test`

---

### Task 1: 先让老人端测试表达新的电信式入口结构

**Files:**
- Modify: `test/widgets/elderly_home_test.dart`

**Step 1: Write the failing test**

增加或调整断言，要求老人端出现新的服务欢迎语、核心入口区和求助入口文案；保留聊天入口和社区入口的行为断言。

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart`
Expected: FAIL，因为当前页面仍是旧的温暖卡片结构和旧文案。

**Step 3: Write minimal implementation**

暂不改实现，让测试先成为明确目标。

**Step 4: Run test to verify it fails for the right reason**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart`
Expected: FAIL，失败点集中在新的首页结构 / 文案期望。

**Step 5: Commit**

```bash
git add test/widgets/elderly_home_test.dart
git commit -m "test: define elderly telecom home expectations"
```

### Task 2: 重构老人端为电信服务大厅式首页

**Files:**
- Modify: `lib/features/elderly/elderly_home_page.dart`
- Test: `test/widgets/elderly_home_test.dart`

**Step 1: Write the failing test**

沿用 Task 1 产生的失败测试，作为老人端重构的唯一目标。

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart`
Expected: FAIL，旧首页结构无法满足新的入口层级。

**Step 3: Write minimal implementation**

重构 `lib/features/elderly/elderly_home_page.dart`：
- 顶部欢迎卡改成更强的服务大厅风格
- 把常用入口重排为电信式服务卡
- 让 `小灵陪你聊聊天` 融入主入口体系但仍保持聊天可达
- 完成手机 / 平板 / 桌面三档响应式排布

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart`
Expected: PASS，首页结构与既有交互都满足新要求。

**Step 5: Commit**

```bash
git add lib/features/elderly/elderly_home_page.dart test/widgets/elderly_home_test.dart
git commit -m "feat: redesign elderly home as telecom service hub"
```

### Task 3: 先让子女端测试表达新的看板结构和响应式目标

**Files:**
- Modify: `test/widgets/child_home_test.dart`

**Step 1: Write the failing test**

新增或调整断言，要求子女端出现家庭关怀总览、状态指标区和提醒时间线的更清晰结构；补充不同视口下关键区域仍存在的回归断言。

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart`
Expected: FAIL，因为当前页面结构还没有新的总览层级和响应式约束。

**Step 3: Write minimal implementation**

暂不改实现，让测试清楚表达子女端看板目标。

**Step 4: Run test to verify it fails for the right reason**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart`
Expected: FAIL，失败原因明确指向新的看板结构尚未实现。

**Step 5: Commit**

```bash
git add test/widgets/child_home_test.dart
git commit -m "test: define child care dashboard expectations"
```

### Task 4: 重构子女端为家庭关怀看板

**Files:**
- Modify: `lib/features/child/child_home_page.dart`
- Test: `test/widgets/child_home_test.dart`

**Step 1: Write the failing test**

沿用 Task 3 的失败状态，确保实现只围绕总览、状态和提醒的新层级展开。

**Step 2: Run test to verify it fails**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart`
Expected: FAIL，旧卡片结构无法满足新断言。

**Step 3: Write minimal implementation**

重构 `lib/features/child/child_home_page.dart`：
- 增加顶部家庭总览区
- 强化状态卡层级和数值表达
- 优化提醒时间线的视觉秩序
- 完成手机 / 平板 / 桌面多端自适应

**Step 4: Run test to verify it passes**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/child_home_test.dart`
Expected: PASS，新的总览与看板结构通过回归。

**Step 5: Commit**

```bash
git add lib/features/child/child_home_page.dart test/widgets/child_home_test.dart
git commit -m "feat: redesign child home as care dashboard"
```

### Task 5: 做整体验证

**Files:**
- Verify only: `lib/features/elderly/elderly_home_page.dart`
- Verify only: `lib/features/child/child_home_page.dart`
- Verify only: `test/widgets/elderly_home_test.dart`
- Verify only: `test/widgets/child_home_test.dart`

**Step 1: Run targeted tests**

Run: `E:/tools/flutter/bin/flutter.bat test test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart`
Expected: PASS，老人端与子女端核心回归通过。

**Step 2: Run full test suite**

Run: `E:/tools/flutter/bin/flutter.bat test`
Expected: PASS，确认没有引入全局回归。

**Step 3: Review diff**

检查改动仅覆盖老人端 / 子女端首页结构、响应式与测试，不引入无关视觉重构。

**Step 4: Verify git status**

Run: `git status --short`
Expected: 只包含本轮相关文件。

**Step 5: Commit**

```bash
git add lib/features/elderly/elderly_home_page.dart lib/features/child/child_home_page.dart test/widgets/elderly_home_test.dart test/widgets/child_home_test.dart docs/plans/2026-03-20-telecom-home-redesign-design.md docs/plans/2026-03-20-telecom-home-redesign-implementation.md
git commit -m "feat: redesign telecom-style home experiences"
```
