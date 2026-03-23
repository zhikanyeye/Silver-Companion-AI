# KittenTTS Railway 部署说明

## 目录

语音服务代码位于：`services/tts/`

## Railway 部署步骤

1. 在 Railway 新建项目
2. 连接 GitHub 仓库
3. 选择服务目录：`services/tts`
4. Railway 会根据 `railway.json` 启动：
   - `uvicorn app:app --host 0.0.0.0 --port $PORT`

## 依赖

服务依赖定义在：`services/tts/requirements.txt`

## 建议环境变量

- `KITTEN_MODEL_NAME=KittenML/kitten-tts-nano-0.8-int8`
- `KITTEN_DEFAULT_VOICE=Bella`

## Flutter 前端接入

前端通过配置项 `tts_api_base_url` 指向该服务，例如：

```json
{
  "model_name": "qwen3-max",
  "tts_api_base_url": "https://your-railway-service.up.railway.app/tts"
}
```

## 验证

部署后用 curl 或 Postman 测试：

```bash
curl -X POST https://your-railway-service.up.railway.app/tts \
  -H "Content-Type: application/json" \
  -d '{"text":"您好，今天感觉怎么样？","voice":"Bella","speed":1.0}' \
  --output test.wav
```

如果返回成功，`test.wav` 应可播放。
