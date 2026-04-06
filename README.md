# Silver Companion AI Demo

Silver Companion AI is a Flutter Web demo focused on elder care scenarios. The project combines:

- AI chat and speech assistance
- Family care dashboard views
- Community mutual-aid interactions
- Lightweight Cloudflare Pages Functions backends

## Current Features

- Elderly side: service hub, AI chat, community feed, activities
- Child side: dashboard overview, charts, reminder timeline
- Settings page: model display and care-mode toggle
- Speech support: browser speech recognition and reply playback
- Server-side API proxy: `/api/chat`, `/api/tts`, `/api/kv`

## Local Development

1. Enable Flutter Web:

```bash
flutter config --enable-web
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run locally:

```bash
flutter run -d chrome
```

4. Run tests:

```bash
flutter test
```

## Deployment Notes

This project should not be deployed as a static `build/web` upload only.

Why:

- chat depends on `functions/api/chat.js`
- speech depends on `functions/api/tts.js`
- KV-backed persistence depends on `functions/api/kv/[key].js`

Recommended deployment mode:

- connect the GitHub repository to Cloudflare Pages
- let Pages build `build/web`
- deploy the repository-root `functions/` directory together with the frontend

Detailed deployment steps:

- [Cloudflare Pages Deployment Guide](docs/cloudflare-pages-deployment.md)

## Cloudflare Pages Configuration

### AI

- `AI_API_KEY`
- `AI_MODEL_NAME`
- `AI_API_BASE_URL`

### TTS

- `TTS_API_BASE_URL`
- `TTS_API_KEY`

### KV

- `SILVER_KV`

Bind `SILVER_KV` in `Settings -> Functions -> KV namespace bindings`.

## Documentation

- [KV Storage Guide](docs/kv-storage-guide.md)
- [Cloudflare Pages Deployment Guide](docs/cloudflare-pages-deployment.md)
- [Demo Script](docs/demo-script.md)
- `docs/plans/` contains implementation and design notes from earlier iterations

## Project Structure

- `lib/`: Flutter app code
- `functions/`: Cloudflare Pages Functions
- `web/`: Flutter Web static assets and config
- `docs/`: deployment and implementation documentation

## KV Storage Summary

KV is currently used for:

- per-identity chat history
- per-identity settings
- community post state
- activities state

See the full guide here:

- [KV Storage Guide](docs/kv-storage-guide.md)
