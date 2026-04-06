# Silver Companion AI Demo / 银龄智伴演示项目

`Silver Companion AI` 是一个面向养老与家庭关怀场景的 Flutter Web 演示项目。  
This project is a Flutter Web demo focused on elder care and family support scenarios.

## 项目包含什么 / What This Project Includes

- AI 聊天与语音辅助 / AI chat and speech assistance
- 子女关怀看板 / family care dashboard views
- 社区互助互动 / community mutual-aid interactions
- Cloudflare Pages Functions 轻量后端 / lightweight Cloudflare Pages Functions backends

## 当前功能 / Current Features

- 老人端：服务大厅、AI 聊天、社区互助、活动页面  
  Elderly side: service hub, AI chat, community feed, activities
- 子女端：概览、图表、提醒时间线  
  Child side: dashboard overview, charts, reminder timeline
- 设置页：模型显示、关怀模式切换  
  Settings page: model display and care-mode toggle
- 语音能力：浏览器语音识别与回复播放  
  Speech support: browser speech recognition and reply playback
- 服务端代理：`/api/chat`、`/api/tts`、`/api/kv`  
  Server-side API proxy: `/api/chat`, `/api/tts`, `/api/kv`

## 本地开发 / Local Development

1. 启用 Flutter Web / Enable Flutter Web

```bash
flutter config --enable-web
```

2. 安装依赖 / Install dependencies

```bash
flutter pub get
```

3. 本地运行 / Run locally

```bash
flutter run -d chrome
```

4. 运行测试 / Run tests

```bash
flutter test
```

## 部署说明 / Deployment Notes

这个项目不适合只上传 `build/web` 作为纯静态站点。  
This project should not be deployed as a static `build/web` upload only.

原因 / Why:

- 聊天依赖 `functions/api/chat.js`
- 语音依赖 `functions/api/tts.js`
- KV 持久化依赖 `functions/api/kv/[key].js`

推荐部署方式 / Recommended deployment mode:

- 将 GitHub 仓库接入 Cloudflare Pages  
  connect the GitHub repository to Cloudflare Pages
- 由 Pages 构建 `build/web`  
  let Pages build `build/web`
- 同时部署仓库根目录下的 `functions/`  
  deploy the repository-root `functions/` directory together with the frontend

详细部署步骤 / Detailed deployment steps:

- [Cloudflare Pages Deployment Guide / Cloudflare Pages 部署指南](docs/cloudflare-pages-deployment.md)

## Cloudflare Pages 配置 / Cloudflare Pages Configuration

### AI

- `AI_API_KEY`
- `AI_MODEL_NAME`
- `AI_API_BASE_URL`

### TTS

- `TTS_API_BASE_URL`
- `TTS_API_KEY`

### KV

- `SILVER_KV`

需要在 `Settings -> Functions -> KV namespace bindings` 中绑定 `SILVER_KV`。  
Bind `SILVER_KV` in `Settings -> Functions -> KV namespace bindings`.

## 文档入口 / Documentation

- [KV Storage Guide / KV 存储使用指南](docs/kv-storage-guide.md)
- [Cloudflare Pages Deployment Guide / Cloudflare Pages 部署指南](docs/cloudflare-pages-deployment.md)
- [Demo Script / 演示脚本](docs/demo-script.md)
- `docs/plans/`：历史设计与实现记录 / historical implementation and design notes

## 目录结构 / Project Structure

- `lib/`：Flutter 应用代码 / Flutter app code
- `functions/`：Cloudflare Pages Functions
- `web/`：Flutter Web 静态资源与配置 / Flutter Web static assets and config
- `docs/`：部署与实现文档 / deployment and implementation documentation

## KV 存储摘要 / KV Storage Summary

当前 KV 用于以下场景：  
KV is currently used for:

- 按 demo 身份隔离的聊天历史 / per-identity chat history
- 按 demo 身份隔离的用户设置 / per-identity settings
- 社区帖子与互动状态 / community post state
- 活动帖子与报名状态 / activities state

完整说明见：  
See the full guide here:

- [KV Storage Guide / KV 存储使用指南](docs/kv-storage-guide.md)
