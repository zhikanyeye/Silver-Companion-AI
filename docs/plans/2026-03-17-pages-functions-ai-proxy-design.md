# 银龄智伴 Cloudflare Pages Functions AI 代理设计文档

## 目标

将当前前端直连 AI 服务的模式改为通过 Cloudflare Pages Functions 提供同源 `/api/chat` 代理接口，统一由服务端持有并使用 `AI_API_KEY`。前端不再保存、展示或传递任何 API Key，首期仅支持 OpenAI 兼容的非流式聊天响应。

## 架构

客户端继续以现有聊天数据结构发起请求，但目标地址改为同源 `/api/chat`。Cloudflare Pages Functions 在服务端读取 `AI_API_KEY`、`AI_MODEL_NAME`、`AI_API_BASE_URL`，将请求转发到上游 OpenAI 兼容接口，并把响应以兼容格式返回前端。
设置页从“本地密钥配置”调整为“服务状态 / 当前模型展示”，前端本地设置中不再持久化任何敏感凭据。后续如需展示非敏感运行配置，可新增只读配置端点，但本阶段不是必需项。

## 请求流程

1. 前端聊天页组装 OpenAI 兼容请求体并调用同源 `/api/chat`。
2. Pages Function 校验请求方法、读取环境变量并补充默认模型。
3. Function 使用 `AI_API_KEY` 调用 `AI_API_BASE_URL` 指定的上游聊天接口。
4. 上游返回 OpenAI 兼容 JSON。
5. Function 透传或规范化响应后返回前端。
6. 前端从响应中读取 assistant 文本并更新会话状态。

## 环境变量

- `AI_API_KEY`：上游 AI 服务密钥，仅配置在 Cloudflare，绝不能下发到前端
- `AI_MODEL_NAME`：默认模型名，由 Functions 注入或兜底使用
- `AI_API_BASE_URL`：OpenAI 兼容上游基础地址，如 OpenRouter/OpenAI 兼容网关

## 前端改动

- `lib/services/settings_store.dart` 不再存储 API Key、Base URL、模型等敏感连接信息
- `lib/features/settings/settings_page.dart` 改为显示服务接入状态、当前模型名、说明文字，不再允许输入或保存 API Key
- `lib/services/openrouter_client.dart` 改为请求同源 `/api/chat`，不再直接拼接带密钥的上游请求
- `lib/features/chat/chat_repository.dart`、`lib/features/chat/chat_controller.dart` 保持聊天调用链，但错误文案要适配“代理不可用 / 服务异常”等场景
- `lib/config/app_config.dart`、`lib/config/config_loader.dart` 去除前端依赖敏感 AI 配置；如保留配置，仅保留非敏感项
- 可选的 `functions/api/config.js` 暂不实现，避免过早扩展

## Functions 改动

- 新增 `functions/api/chat.js`
- 仅接受 `POST`
- 接收并校验 OpenAI 兼容请求体，首期支持非流式 `messages` 聊天请求
- 使用 `AI_API_KEY`、`AI_MODEL_NAME`、`AI_API_BASE_URL` 转发到上游 `chat/completions` 类接口
- 返回 OpenAI 兼容响应结构，便于前端最小改动接入
- 统一添加 CORS/JSON/错误响应处理（同源场景下保持简单即可）

## 错误处理

- 缺少环境变量：返回 `500`，提示服务端配置缺失
- 非法方法：返回 `405`
- 请求体无效：返回 `400`
- 上游鉴权失败或额度问题：返回上游状态码并隐藏敏感细节
- 上游超时或不可达：返回 `502/504`
- 前端统一展示“服务暂不可用”类文案，不暴露密钥、完整上游地址或内部堆栈

## 测试

- `flutter test` 覆盖客户端不再持久化 API Key 的行为
- `flutter test` 覆盖设置页仅展示服务状态/模型信息的 UI 行为
- `flutter test` 覆盖聊天仓库/控制器对 `/api/chat` 成功与失败响应的处理
- 手动验证 Cloudflare 环境变量配置正确后，确认浏览器网络请求仅访问同源 `/api/chat`
- 手动确认任何前端存储、日志、设置页与请求体中都不出现 `AI_API_KEY`

## 不在范围内

- 流式响应 / SSE
- 前端动态远程配置拉取
- 多模型切换 UI
- Functions 鉴权体系扩展
- 历史消息压缩、重试队列、限流与观测平台接入
