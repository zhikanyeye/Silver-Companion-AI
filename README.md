# 银龄智伴 Demo

银龄智伴是一个面向老年群体的智慧养老平台演示项目，核心模式为：

- AI虚拟家人（情感陪伴、语音交互、反诈提醒）
- 社区互助网络（类似社交信息流的互助发布与浏览）
- 子女关怀看板（状态概览与预警信息）

## 当前功能

- 老人端：首页入口、AI聊天页、反诈提示、社区互助信息流
- 子女端：状态卡片、预警列表
- 设置页：云端服务状态与模型信息展示
- Web Speech：浏览器端语音识别/语音播报桥接
- AI 请求：通过 Cloudflare Pages Functions 的同源 `/api/chat` 代理转发

## 本地运行

1. 安装 Flutter（建议使用稳定版）并启用 Web：

```bash
flutter config --enable-web
```

2. 拉取依赖：

```bash
flutter pub get
```

3. 运行 Web 调试：

```bash
flutter run -d chrome
```

4. 运行测试：

```bash
flutter test
```

## 部署说明

当前版本如果要使用真实 AI 对话，**不要再使用 Direct Upload 只上传 `build/web`**。

原因：
- 聊天能力依赖 `functions/api/chat.js`
- 该接口需要 Cloudflare Pages Functions 和环境变量
- 只上传静态产物不会把 Functions 一起部署

推荐部署方式：
- GitHub 仓库接入 Cloudflare Pages
- 由 Cloudflare 在构建阶段生成 `build/web`
- 同时部署仓库根目录下的 `functions/`

详细步骤请查看：

- [Cloudflare Pages 部署说明](docs/cloudflare-pages-deployment.md)


## Cloudflare Pages 关键环境变量

在 Cloudflare Pages 中至少配置：

- `AI_API_KEY`
- `AI_MODEL_NAME`
- `AI_API_BASE_URL`

说明：
- `AI_API_BASE_URL` 需要填写 OpenAI 兼容接口的基础地址
- 不要包含 `/chat/completions`
- 真实调用由 Cloudflare Pages Functions 完成，前端不再保存 API Key

## 目录与文档说明

- `lib/`：Flutter 应用代码
- `functions/`：Cloudflare Pages Functions
- `web/`：Flutter Web 静态资源模板
- `docs/`：项目相关文档与部署说明，主要包括：
  - [**项目 Demo 演示脚本**](docs/demo-script.md)
  - [**Cloudflare Pages 自动部署指南**](docs/cloudflare-pages-deployment.md)
  - `docs/plans/`：详尽的功能演进记录日志（涵盖UI统一设计、响应式布局重构、长辈/子女端隔离、服务端网关搭建等设计与实现计划）

## 当前部署方式变更

旧方式：
- 构建 `build/web`
- Direct Upload 到 Cloudflare Pages

当前推荐方式：
- GitHub 仓库接入 Cloudflare Pages
- 配置构建命令与输出目录
- 配置 Pages 环境变量
- 由 Pages 自动部署静态站点与 Functions
