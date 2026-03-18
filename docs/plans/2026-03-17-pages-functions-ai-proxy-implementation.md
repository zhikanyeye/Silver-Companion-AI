# 银龄智伴 Cloudflare Pages Functions AI 代理实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将前端聊天调用切换到 Cloudflare Pages Functions 同源 `/api/chat` 代理，并彻底移除前端对 API Key 的保存与展示。

**Architecture:** 由 `functions/api/chat.js` 负责读取 Cloudflare 环境变量并转发 OpenAI 兼容非流式聊天请求，Flutter 端仅请求同源代理。设置页和本地存储去敏，聊天仓库与控制器保留现有职责但改为处理代理成功/失败结果。首版不引入 `functions/api/config.js`，避免增加不必要接口面。

**Tech Stack:** Cloudflare Pages Functions, JavaScript, Flutter/Dart, `flutter test`, OpenAI-compatible chat completions API

---

### Task 1: 移除前端本地敏感配置持久化

**Files:**
- Modify: `lib/services/settings_store.dart`
- Modify: `lib/config/app_config.dart`
- Modify: `lib/config/config_loader.dart`
- Test: `test/features/settings/settings_store_test.dart`

**Step 1: Write the failing test**

在 `test/features/settings/settings_store_test.dart` 增加用例，断言设置存储不会再读写 API Key、上游 Base URL、模型覆盖等敏感字段；仅保留非敏感设置。

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/settings/settings_store_test.dart`
Expected: FAIL，出现旧字段仍被保存/读取或测试期望不匹配。

**Step 3: Write minimal implementation**

更新 `lib/services/settings_store.dart`，删除 API Key 等敏感字段的持久化逻辑；同步清理 `lib/config/app_config.dart` 与 `lib/config/config_loader.dart` 中前端必填敏感 AI 配置定义，仅保留非敏感配置或默认值。

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/settings/settings_store_test.dart`
Expected: PASS，确认本地设置不再包含敏感 AI 凭据。

**Step 5: Commit**

```bash
git add lib/services/settings_store.dart lib/config/app_config.dart lib/config/config_loader.dart test/features/settings/settings_store_test.dart
git commit -m "refactor: remove persisted AI credentials from frontend settings"
```

### Task 2: 将设置页改为服务状态与模型展示

**Files:**
- Modify: `lib/features/settings/settings_page.dart`
- Test: `test/widgets/settings_entry_test.dart`

**Step 1: Write the failing test**

在 `test/widgets/settings_entry_test.dart` 增加用例，断言设置页不再出现 API Key 输入/保存入口，而是展示服务说明、代理接入状态占位文案、当前模型展示文案。

**Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/settings_entry_test.dart`
Expected: FAIL，页面仍渲染密钥输入项或缺少新文案。

**Step 3: Write minimal implementation**

修改 `lib/features/settings/settings_page.dart`，移除 API Key 与上游地址输入控件，改为只读状态卡片；模型名可先来自本地非敏感配置或静态说明，不新增 `functions/api/config.js`。

**Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/settings_entry_test.dart`
Expected: PASS，确认设置页只展示服务状态/模型信息。

**Step 5: Commit**

```bash
git add lib/features/settings/settings_page.dart test/widgets/settings_entry_test.dart
git commit -m "feat: convert settings page to service status view"
```

### Task 3: 将聊天客户端切换到同源 `/api/chat`

**Files:**
- Create: `functions/api/chat.js`
- Modify: `lib/services/openrouter_client.dart`
- Modify: `lib/features/chat/chat_repository.dart`
- Test: `test/services/openrouter_client_test.dart`
- Create: `test/features/chat/chat_repository_test.dart`

**Step 1: Write the failing test**

在 `test/services/openrouter_client_test.dart` 增加用例，断言客户端向同源 `/api/chat` 发送 OpenAI 兼容非流式请求，且请求中不包含 API Key。
在 `test/features/chat/chat_repository_test.dart` 增加用例，断言仓库能解析代理返回的 OpenAI 兼容响应。

**Step 2: Run test to verify it fails**

Run: `flutter test test/services/openrouter_client_test.dart test/features/chat/chat_repository_test.dart`
Expected: FAIL，客户端仍直连上游或仍依赖本地密钥配置。

**Step 3: Write minimal implementation**

实现 `functions/api/chat.js`：读取 `AI_API_KEY`、`AI_MODEL_NAME`、`AI_API_BASE_URL`，只接受 `POST`，转发到上游 OpenAI 兼容聊天接口并返回 JSON。
修改 `lib/services/openrouter_client.dart` 指向同源 `/api/chat`；同步调整 `lib/features/chat/chat_repository.dart` 的请求/响应映射。

**Step 4: Run test to verify it passes**

Run: `flutter test test/services/openrouter_client_test.dart test/features/chat/chat_repository_test.dart`
Expected: PASS，确认客户端改走同源代理且响应解析正常。

**Step 5: Commit**

```bash
git add functions/api/chat.js lib/services/openrouter_client.dart lib/features/chat/chat_repository.dart test/services/openrouter_client_test.dart test/features/chat/chat_repository_test.dart
git commit -m "feat: route chat requests through Cloudflare Pages proxy"
```

### Task 4: 完成聊天控制器错误处理与回归验证

**Files:**
- Modify: `lib/features/chat/chat_controller.dart`
- Modify: `lib/features/chat/chat_repository.dart`
- Test: `test/features/chat/chat_controller_test.dart`
- Test: `test/services/openrouter_client_test.dart`

**Step 1: Write the failing test**

在 `test/features/chat/chat_controller_test.dart` 增加用例，覆盖代理返回 `400`、`500`、`502/504` 时的用户可见错误状态；必要时补充 `test/services/openrouter_client_test.dart` 用例验证错误映射。

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/chat/chat_controller_test.dart test/services/openrouter_client_test.dart`
Expected: FAIL，当前错误提示仍偏向前端密钥缺失或无法正确映射代理错误。

**Step 3: Write minimal implementation**

更新 `lib/features/chat/chat_controller.dart` 与必要的 `lib/features/chat/chat_repository.dart` 错误处理逻辑，统一输出“服务未配置”“服务暂不可用”“请求无效”等代理语义错误，不暴露密钥或上游内部细节。

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/chat/chat_controller_test.dart test/services/openrouter_client_test.dart`
Expected: PASS，聊天链路在成功与常见失败场景下行为稳定。

**Step 5: Commit**

```bash
git add lib/features/chat/chat_controller.dart lib/features/chat/chat_repository.dart test/features/chat/chat_controller_test.dart test/services/openrouter_client_test.dart
git commit -m "fix: map proxy errors to user-safe chat states"
```
