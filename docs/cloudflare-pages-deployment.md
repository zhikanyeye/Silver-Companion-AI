# Cloudflare Pages Deployment Guide / Cloudflare Pages 部署指南

本文说明如何把当前 `Yinling` 项目部署到 Cloudflare Pages。  
This guide explains how to deploy the current `Yinling` project to Cloudflare Pages.

## 部署模型 / Deployment Model

当前项目由以下部分组成：  
The current app uses:

- Flutter Web 前端 / Flutter Web frontend
- Cloudflare Pages Functions 后端路由 / backend routes
- Cloudflare KV 轻量持久化 / lightweight persistence

重要：如果你希望聊天、语音和 KV 功能都能工作，不要只上传 `build/web`。  
Important: do not deploy only `build/web` as a static upload if you expect chat, speech, or KV features to work.

以下后端文件必须随前端一起部署：  
The following backend files must be deployed together with the frontend:

- `functions/api/chat.js`
- `functions/api/tts.js`
- `functions/api/kv/[key].js`
- `functions/api/community.js`
- `functions/api/community/[postId]/respond.js`
- `functions/api/activities.js`
- `functions/api/activities/[activityId]/join.js`

## 部署前准备 / Prerequisites

开始前请确认：  
Before starting, confirm:

- GitHub 仓库可访问 / the repository is available in GitHub
- 目标分支包含当前 `functions/` 和 `lib/` 代码 / the target branch contains the current `functions/` and `lib/` code
- 本地可以正常构建 / the project builds locally

```bash
flutter pub get
flutter test
flutter build web --release --no-wasm-dry-run
```

## 创建 Pages 项目 / Create the Pages Project

1. 打开 Cloudflare Dashboard / Open the Cloudflare Dashboard
2. 进入 `Workers & Pages`
3. 点击 `Create application`
4. 选择 `Pages`
5. 选择 `Connect to Git`
6. 如有需要，连接 GitHub 账号 / connect your GitHub account if needed
7. 选择当前仓库 / select this repository
8. 选择要部署的分支 / select the branch you want to deploy

## 构建配置 / Build Settings

项目根目录使用仓库根目录。  
Use the repository root as the project root.

建议的构建命令 / Suggested build command:

```bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter" && export PATH="$HOME/flutter/bin:$PATH" && flutter config --enable-web && flutter pub get && flutter build web --release --no-wasm-dry-run
```

构建产物目录 / Build output directory:

```text
build/web
```

## 环境变量 / Environment Variables

在 `Settings -> Environment variables` 中配置，按需分别给 Preview 和 Production 设置。  
Configure these in `Settings -> Environment variables` for both Preview and Production as needed.

### AI

- `AI_API_KEY`
- `AI_MODEL_NAME`
- `AI_API_BASE_URL`

`AI_API_BASE_URL` 只能填 API 基础地址，不要包含 `/chat/completions`。  
`AI_API_BASE_URL` should be the API base only. Do not include `/chat/completions`.

例如 / Examples:

```text
https://api.openai.com/v1
```

```text
https://openrouter.ai/api/v1
```

### TTS

- `TTS_API_BASE_URL`
- `TTS_API_KEY`

## KV 绑定 / KV Binding

KV 绑定是必需的，否则这些功能会失败：  
KV binding is required, otherwise these features will fail:

- 聊天历史同步 / chat history sync
- 设置同步 / settings sync
- 社区发布/响应 / community publish/respond
- 活动发布/报名 / activities publish/join

### 必须使用的绑定名 / Required binding name

```text
SILVER_KV
```

### 配置步骤 / Setup Steps

1. 在 Cloudflare Dashboard 中打开 `Workers & Pages -> KV`  
   Open `Workers & Pages -> KV`
2. 创建一个新的 namespace，例如 `SilverCompanionKV`  
   Create a new namespace, for example `SilverCompanionKV`
3. 打开你的 Pages 项目 / Open your Pages project
4. 进入 `Settings -> Functions`
5. 找到 `KV namespace bindings`
6. 点击 `Add binding`
7. 把 `Variable name` 设置为 `SILVER_KV`
8. 选择刚才创建的 namespace
9. 如有需要，在 Preview 和 Production 都重复配置  
   Repeat for both Preview and Production if needed

## 触发部署 / Trigger a Deployment

你可以通过以下方式触发部署：  
You can trigger deployment by:

- 在 Pages UI 里点击重新部署 / retrying a deployment in the Pages UI
- 向目标分支 push 新提交 / pushing a new commit to the configured branch
- 切换 Pages 绑定分支后重新部署 / switching the connected branch in Pages and deploying again

## 部署后验证 / Post-Deployment Verification

部署完成后，至少检查以下内容：  
After deployment, verify at least the following:

### 前端页面 / Frontend

- 首页可以打开 / landing page loads
- 登录注册流程可用 / login/register flow works
- 身份选择页面可用 / role selection works
- 老人端和子女端可以打开 / elderly and child pages render

### 网络请求 / Network

在浏览器开发者工具中确认前端请求的是：  
In browser devtools, confirm the frontend uses:

```text
/api/chat
/api/tts
/api/kv
```

浏览器不应该暴露以下密钥：  
The browser should not expose:

- `AI_API_KEY`
- `TTS_API_KEY`

### 功能验证 / Feature Checks

- 至少发送一条聊天消息成功  
  send one chat message successfully
- 如已配置语音服务，确认 `/api/tts` 可用  
  speech route responds when configured
- 设置页能读到模型值  
  settings page loads model value
- 社区页能加载  
  community feed can load
- 活动页能加载  
  activities page can load

## 故障排查 / Troubleshooting

### 聊天返回 500 / Chat returns 500

通常表示：  
Usually means:

- `AI_API_KEY` 缺失 / is missing
- `AI_API_BASE_URL` 缺失 / is missing
- `AI_MODEL_NAME` 缺失或无效 / is missing or invalid

### 聊天返回 502 / Chat returns 502

通常表示：  
Usually means:

- 上游 AI 服务不可用 / upstream AI service is unavailable
- 上游返回了异常响应 / upstream returned an unexpected response

### 所有 KV 相关功能都失败 / KV-backed features fail

请检查：  
Check:

- `SILVER_KV` 已绑定 / is bound
- 当前环境里绑定存在 / binding exists in the active environment
- Pages Functions 确实从仓库根目录部署 / Pages Functions are deployed from the repo root

### 静态页面能打开，但 API 不工作 / Static site works but APIs do not

这通常说明只部署了 `build/web`，没有部署 `functions/`。  
This usually means only `build/web` was uploaded and `functions/` was not deployed.

## 相关文档 / Related Documentation

- [KV Storage Guide / KV 存储使用指南](kv-storage-guide.md)
