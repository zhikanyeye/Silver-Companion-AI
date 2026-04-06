# KV Storage Guide / KV 存储使用指南

本文说明项目里 KV 的用途、部署要求，以及本地开发和测试时的行为。  
This document explains how KV-backed storage is used in the project, how it is deployed on Cloudflare Pages, and what to expect in local development and tests.

## 概览 / Overview

项目使用 Cloudflare KV 做轻量级持久化，用于保存需要跨刷新、跨会话保留的数据。  
The app uses Cloudflare KV for lightweight persisted state that should survive page refreshes and be available across sessions.

当前接入 KV 的功能包括：  
Current KV-backed flows:

- 聊天历史 / Chat history
- 用户设置 / User settings
- 社区互助的帖子与互动状态 / Community feed engagement state and newly published posts
- 老人活动的帖子与报名状态 / Elderly activities engagement state and newly published activities

前端不会直接访问 Cloudflare KV，而是统一走 Pages Functions。  
The frontend does not talk to Cloudflare KV directly. It always goes through Pages Functions under `functions/api/`.

## 存储架构 / Storage Architecture

### 前端 / Frontend

前端通过以下服务类读写：  
The frontend reads and writes through service classes:

- `lib/services/kv_client.dart`
- `lib/services/settings_store.dart`
- `lib/features/chat/chat_controller.dart`
- `lib/features/community/community_feed_service.dart`
- `lib/features/elderly/elderly_activities_service.dart`
- `lib/services/demo_identity_store.dart`

### 后端 / Backend

真正访问 KV 的是 Cloudflare Pages Functions：  
Cloudflare Pages Functions own the actual KV access:

- `functions/api/kv/[key].js`
- `functions/api/community.js`
- `functions/api/community/[postId]/respond.js`
- `functions/api/activities.js`
- `functions/api/activities/[activityId]/join.js`
- `functions/api/_lib/engagement_store.js`

## Key 命名规则 / Key Naming Rules

### 按身份隔离的 key / Per-identity keys

项目会生成一个 demo identity，并用它隔离用户数据。  
The app generates a demo identity and uses it to isolate user-specific data.

示例 / Examples:

- 聊天历史：`chat_history_<actorId>` / Chat history
- 用户设置：`user_settings_<actorId>` / Settings

其中 `<actorId>` 来自 `DemoIdentityStore`。  
`<actorId>` comes from `DemoIdentityStore`.

这意味着不同 demo 用户不会互相覆盖。  
This means different demo users do not overwrite each other inside the same KV namespace.

### 社区与活动 key / Community and Activities Keys

社区和活动数据采用一个简单的“索引 + item + action”模型。  
Community and activity data use a small indexed storage model.

示例 / Examples:

- 索引：`<prefix>:index` / Item index
- 数据项：`<prefix>:item:<id>` / Item payload
- 用户动作标记：`<prefix>:action:<id>:<action>:<actorId>` / User action marker

当前使用的 prefix：  
Concrete prefixes currently used:

- `community`
- `activities`

## 数据结构 / Data Shapes

### 聊天历史 / Chat History

存储结构示例 / Stored value:

```json
{
  "messages": [
    {
      "role": "user",
      "content": "Hello",
      "createdAt": "2026-04-06T12:34:56.000Z"
    }
  ]
}
```

### 用户设置 / Settings

存储结构示例 / Stored value:

```json
{
  "model": "openai/gpt-4o-mini"
}
```

### 社区和活动 / Community and Activities

社区帖子和活动记录本体存成 item JSON，再配合 index 保存顺序。  
Community posts and activity records are stored as item JSON plus an index list.

用户自己的响应/报名状态通过 action marker 单独保存，从而让后端计算这些字段：  
User-specific response/join state is stored separately via action markers so the backend can derive flags like:

- `respondedByMe`
- `joinedByMe`

## 回退策略 / Fallback Behavior

### 设置 / Settings

`SettingsStore` 的读取顺序是：  
`SettingsStore` uses this order:

1. 远端 KV / Remote KV
2. 本地 `SharedPreferences`
3. 构建时默认值 / Build-time fallback default

### 聊天历史 / Chat History

`ChatController` 会先尝试按当前 demo 身份从 KV 读取聊天记录。  
`ChatController` tries to load chat history from KV using the current demo identity key.

如果 KV 不可用，聊天功能仍可在当前会话里使用。  
If KV is unavailable, chat still works for the current session.

### 社区与活动 / Community and Activities

社区和活动接口失败时，会回退到内置 mock 数据。  
Community and activities services fall back to bundled mock data if the backend call fails.

## Cloudflare 部署要求 / Cloudflare Deployment Requirements

你必须在 Pages 项目中绑定一个名为 `SILVER_KV` 的 KV namespace。  
You must bind a KV namespace to the Pages project using the variable name:

```text
SILVER_KV
```

如果没有这个绑定，这些功能会失败：  
Without this binding:

- 聊天历史同步 / Chat history sync
- 设置同步 / Settings sync
- 社区发布/响应 / Community publish/respond
- 活动发布/报名 / Activity publish/join

详细步骤同时见：  
Detailed setup steps are also documented in:

- `docs/cloudflare-pages-deployment.md`

## 本地开发说明 / Local Development Notes

### 本地没有 Pages 绑定时 / Running Locally Without Pages Bindings

普通 Flutter 本地开发时，通常没有真正可用的 KV 后端。  
In plain Flutter local runs, you may not have a working KV-backed backend.

这时会出现：

- 设置可能回退到本地偏好 / Settings may fall back to local preferences
- 聊天可能没有远端历史恢复 / Chat may run without persisted remote history
- 社区和活动会回退到 mock 数据 / Community and activities may fall back to mock data

### 前端默认访问地址 / Base Path Used by the Frontend

`KvClient` 默认访问：

```text
/api/kv
```

也可以用构建时环境值覆盖：  
This can be overridden with the build-time environment value:

```text
AI_KV_URL
```

## 测试环境说明 / Test Environment Notes

在 Flutter widget test 环境里，真实 HTTP 会被测试绑定拦截。  
In Flutter widget tests, real HTTP is blocked by the test binding.

因此你可能会看到日志：  
Because of that, you may still see log lines like:

- `KV Get Error (400)`
- `KV Put Error (400)`

这些日志是预期现象，不代表测试失败。  
These logs are expected when a widget test touches code that would normally issue an HTTP request. They do not mean the test failed.

如果测试需要稳定控制 KV 行为，应注入 fake `KvClient` 或 fake `DemoIdentityStore`。  
Where tests need deterministic KV behavior, they should inject a fake `KvClient` or a fake `DemoIdentityStore`.

## 常见问题 / Troubleshooting

### 现象：设置刷新后不保留  
### Symptom: settings do not persist across refreshes

检查：

- `SILVER_KV` 是否已绑定 / is bound in Pages
- `functions/api/kv/[key].js` 是否已部署 / route is deployed
- 前端是否还在使用同一个 demo identity / frontend is loading the same demo identity

### 现象：聊天能发，但旧消息不会回来  
### Symptom: chat works but old messages do not come back

检查：

- KV 绑定是否存在 / KV binding exists
- `actorId` 是否变了 / the generated `actorId` did not change
- `chat_history_<actorId>` 是否写入成功 / is being written successfully

### 现象：社区或活动的发布/响应/报名失败  
### Symptom: publish/respond/join fails in community or activities

检查：

- Preview 和 Production 是否都绑定了 KV / KV binding exists in both Preview and Production
- Pages Functions 是否从仓库根目录部署 / Pages Functions are deployed from the repo root
- 对应函数接口是否返回 200/201 而不是 500 / relevant function routes return 200/201 instead of 500

## 维护建议 / Recommended Maintenance

以后 KV 行为发生变化时，建议同时更新这三处文档：  
When KV behavior changes, update all three places together:

1. `docs/kv-storage-guide.md`
2. `README.md`
3. `docs/cloudflare-pages-deployment.md`
