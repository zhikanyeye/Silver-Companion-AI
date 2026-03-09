# 银龄智伴 Demo

银龄智伴是一个面向老年群体的智慧养老平台演示项目，核心模式为：

- AI虚拟家人（情感陪伴、语音交互、反诈提醒）
- 社区互助网络（类似社交信息流的互助发布与浏览）
- 子女关怀看板（状态概览与预警信息）

## 当前功能

- 老人端：首页入口、AI聊天页、反诈提示、社区互助信息流
- 子女端：状态卡片、预警列表
- 设置页：OpenRouter API Key 与模型配置
- Web Speech：浏览器端语音识别/语音播报桥接

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

## 构建与部署（Cloudflare Pages）

1. 构建产物：

```bash
flutter build web --release
```

2. 打开 Cloudflare Pages，选择 Direct Upload，上传 `build/web` 目录。

3. 若需真实 AI 对话，在 Cloudflare Pages 配置环境变量：

- `OPENROUTER_API_KEY`
- `OPENROUTER_MODEL`（示例：`openai/gpt-4o-mini`）
