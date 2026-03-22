# 银龄智伴服务端模型优先设计文档

## 目标

确保聊天请求最终使用 Cloudflare Pages 环境变量中的 `AI_MODEL_NAME`，而不是被前端请求体里的默认模型覆盖。这样模型选择权完全回到服务端配置，便于在不改前端构建产物的情况下切换到千问等兼容模型。

## 问题确认

当前 `functions/api/chat.js` 中的逻辑是：

- 先读取前端传来的 `requestBody.model`
- 再以它覆盖 `AI_MODEL_NAME`

这会导致：

- 前端默认仍传 `openai/gpt-4o-mini`
- 即使 Pages 里配置了 `AI_MODEL_NAME=qwen3-max`，最终仍然走前端默认模型

## 设计决策

采用“服务端模型优先”的最小修复方案：

- `functions/api/chat.js` 优先使用 `AI_MODEL_NAME`
- 仅当服务端没有配置模型名时，才考虑前端请求体中的 `model`
- 同时前端客户端不再在请求体里发送 `model` 字段，避免继续制造混淆

## 范围

- 修改 Cloudflare Pages Functions 模型选择逻辑
- 修改 Flutter 客户端请求体，去掉模型字段传输
- 补充函数级回归测试和客户端回归测试

## 测试策略

- 为 `functions/api/chat.js` 增加 Node 测试：
  - 服务端配置了 `AI_MODEL_NAME` 时，忽略前端 `model`
  - 服务端未配置 `AI_MODEL_NAME` 时，可回退使用请求体里的 `model`
- 更新 `test/services/openrouter_client_test.dart`，确认客户端不再发送 `model`
- 跑相关测试，再跑一遍 `flutter test`

## 不在范围内

- 修复 Cloudflare Production 环境变量未生效的问题本身
- 增加环境变量诊断接口
- 修改聊天页 UI
