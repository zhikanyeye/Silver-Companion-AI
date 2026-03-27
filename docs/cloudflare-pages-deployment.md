# Cloudflare Pages 部署指南

本文档适用于当前银龄智伴仓库的部署方式：
- 代码托管在 GitHub
- 前端使用 Flutter Web
- AI 请求通过 Cloudflare Pages Functions 的同源接口 `/api/chat` 代理
- 大模型密钥、模型名、上游地址全部放在 Cloudflare 环境变量中

## 1. 部署前确认

在开始前，请确认以下内容已经满足：

- GitHub 仓库已经可访问
- 目标分支已经包含以下关键文件：
  - `functions/api/chat.js` (AI 对话代理)
  - `functions/api/tts.js` (TTS 语音代理)
  - `lib/services/openrouter_client.dart`
  - `lib/services/tts_client.dart`
- 仓库根目录可以正常执行：

```bash
flutter pub get
flutter test
flutter build web --release --no-wasm-dry-run
```

## 2. 当前部署方式的变化

当前版本不再适合只上传 `build/web` 静态文件。


原因：
- AI 对话和语音合成依赖同源代理接口 `/api/chat` 和 `/api/tts`
- 这些代理接口由 Cloudflare Pages Functions 提供
- 如果只上传静态产物，Functions 不会一起部署，核心能力将无法工作

因此，推荐使用：
- GitHub 仓库接入 Cloudflare Pages
- 由 Cloudflare 在构建时同时处理 `build/web` 和 `functions/`

## 3. 在 Cloudflare Pages 创建项目

1. 打开 Cloudflare Dashboard
2. 进入 `Workers & Pages`
3. 点击 `Create application`
4. 选择 `Pages`
5. 选择 `Connect to Git`
6. 连接你的 GitHub 账号
7. 选择仓库：`Silver-Companion-AI`
8. 选择要部署的分支

建议：
- 如果你当前先验证代理功能，选择包含 `functions/api/chat.js` 的功能分支
- 验证通过后，再切回 `main` 作为生产分支

## 4. 构建配置

在 Cloudflare Pages 的构建设置中，使用以下配置：

- **Framework preset**：`None`
- **Root directory**：仓库根目录
- **Build command**：

```bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter" && export PATH="$HOME/flutter/bin:$PATH" && flutter config --enable-web && flutter pub get && flutter build web --release --no-wasm-dry-run
```

- **Build output directory**：

```text
build/web
```

说明：
- Cloudflare 默认构建镜像通常不自带 Flutter，所以这里在构建阶段临时拉取 Flutter stable
- `functions/` 目录位于仓库根目录，Cloudflare Pages 会自动识别并部署 Functions

## 5. 配置环境变量

进入该 Pages 项目的 `Settings -> Environment variables`，分别在 `Production` 和需要的 `Preview` 环境中配置：

### 必填变量

- `AI_API_KEY`
  - 你的大模型服务密钥

- `AI_MODEL_NAME`
  - 默认模型名称
  - 示例：
    - `gpt-4o-mini`
    - 或国产兼容模型名，例如 `qwen-plus`、`deepseek-chat` 等

- `AI_API_BASE_URL`
  - OpenAI 兼容接口的基础地址
  - 注意：**不要包含** `/chat/completions`
  - 正确示例：

```text
https://api.openai.com/v1
```

```text
https://openrouter.ai/api/v1
```

如果你使用国产兼容网关，也应填写其 `/v1` 级别基础地址。

### 为什么不能带 `/chat/completions`

因为 `functions/api/chat.js` 会自动把地址拼接为：

```text
${AI_API_BASE_URL}/chat/completions
```

如果你把完整路径直接填进去，请求就会变成重复路径，导致调用大模型失败。

### EdgeTTS 语音服务必填变量

针对高质量语音合成功能（采用 Cloudflare Workers WebUI Enhanced 版 EdgeTTS）：

- `TTS_API_BASE_URL`
  - 你部署的 EdgeTTS WebUI 服务的域名
  - 示例：`https://your-edgetts-app.pages.dev`
- `TTS_API_KEY`
  - 对应的安全访问密码/API Key

## 6. 触发部署

配置完成后可以通过以下任一方式触发构建：

- 在 Cloudflare Pages 页面点击 `Retry deployment`
- 向所选分支推送新提交
- 切换 Pages 绑定分支后触发新构建

## 7. 部署后验证

部署成功后，按下面顺序做一遍验证：

### 页面验证

1. 打开站点首页
2. 点击右上角 `登录` 或 `注册`
3. 完成认证页表单
4. 进入身份选择页
5. 进入老人端后打开 AI 聊天页

### 网络验证

打开浏览器开发者工具，确认：
- 前端请求的是同源接口：

```text
/api/chat
/api/tts
```

- 前端**不会**直接请求第三方模型地址或 TTS 地址
- 浏览器网络请求中**绝对不会**出现 `AI_API_KEY` 或 `TTS_API_KEY`

### 功能验证

发送一条简单消息，例如：

```text
你好，请介绍一下你自己
```

若返回正常，即说明：
- Pages Functions 已生效
- 环境变量已被正确读取
- 上游大模型接口和 EdgeTTS 语音接口均可用

## 8. 常见问题排查

### 1）站点能打开，但聊天报错

优先检查：
- `AI_API_KEY` 是否正确
- `AI_MODEL_NAME` 是否是供应商真实支持的模型名
- `AI_API_BASE_URL` 是否填写成了完整 `chat/completions` 路径

### 2）聊天请求返回 500

通常说明：
- Pages 环境变量没配全
- `AI_API_KEY` 或 `AI_API_BASE_URL` 为空
- `AI_MODEL_NAME` 为空且前端请求也没传模型

### 3）聊天请求返回 502

通常说明：
- Cloudflare 能收到请求
- 但上游模型服务不可达或返回了非 JSON 内容

建议检查：
- 上游服务地址是否正确
- 所在区域是否能访问该模型服务
- 该服务是否需要额外头信息或账号开通

### 4）只上传了 `build/web` 之后聊天失效

这是预期现象，因为只上传静态文件不会带上：

- `functions/api/chat.js`
- Cloudflare 环境变量

要恢复聊天，必须重新走 Pages 项目部署。

## 9. 当前代码行为说明

当前版本里：
- 前端设置页不再保存 API Key
- 设置页只显示服务状态和模型信息
- 真实模型调用由 Cloudflare Pages Functions 代理完成
- 前端聊天客户端只请求同源 `/api/chat`

## 10. 推荐上线顺序

建议按这个顺序推进：

1. 先把包含代理代码的分支接入 Cloudflare Pages
2. 配好 3 个环境变量
3. 先做一次线上聊天验证
4. 再继续做老人端 / 子女端的电信风格重构
