# Cloudflare Pages Deployment Guide

This guide describes how to deploy the current Silver Companion AI demo to Cloudflare Pages.

## Deployment Model

The current app uses:

- Flutter Web for the frontend
- Cloudflare Pages Functions for backend routes
- Cloudflare KV for lightweight persistence

Important: do not deploy only `build/web` as a static upload if you expect chat, speech, or KV features to work.

The following backend files must be deployed together with the frontend:

- `functions/api/chat.js`
- `functions/api/tts.js`
- `functions/api/kv/[key].js`
- `functions/api/community.js`
- `functions/api/community/[postId]/respond.js`
- `functions/api/activities.js`
- `functions/api/activities/[activityId]/join.js`

## Prerequisites

Before starting, confirm:

- the repository is available in GitHub
- the target branch contains the current `functions/` and `lib/` code
- the project builds locally:

```bash
flutter pub get
flutter test
flutter build web --release --no-wasm-dry-run
```

## Create the Pages Project

1. Open the Cloudflare Dashboard.
2. Go to `Workers & Pages`.
3. Click `Create application`.
4. Choose `Pages`.
5. Choose `Connect to Git`.
6. Connect your GitHub account if needed.
7. Select this repository.
8. Select the branch you want to deploy.

## Build Settings

Use the repository root as the project root.

Suggested build command:

```bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter" && export PATH="$HOME/flutter/bin:$PATH" && flutter config --enable-web && flutter pub get && flutter build web --release --no-wasm-dry-run
```

Build output directory:

```text
build/web
```

## Environment Variables

Configure these in `Settings -> Environment variables` for both Preview and Production as needed.

### AI

- `AI_API_KEY`
- `AI_MODEL_NAME`
- `AI_API_BASE_URL`

`AI_API_BASE_URL` should be the API base only. Do not include `/chat/completions`.

Examples:

```text
https://api.openai.com/v1
```

```text
https://openrouter.ai/api/v1
```

### TTS

- `TTS_API_BASE_URL`
- `TTS_API_KEY`

## KV Binding

KV binding is required for chat history sync, settings sync, community publish/respond, and activities publish/join.

### Required binding name

```text
SILVER_KV
```

### Setup steps

1. In the Cloudflare Dashboard, open `Workers & Pages -> KV`.
2. Create a new namespace, for example `SilverCompanionKV`.
3. Open your Pages project.
4. Go to `Settings -> Functions`.
5. Find `KV namespace bindings`.
6. Click `Add binding`.
7. Set `Variable name` to `SILVER_KV`.
8. Select the namespace you created.
9. Repeat for both Preview and Production if needed.

## Trigger a Deployment

You can trigger deployment by:

- retrying a deployment in the Pages UI
- pushing a new commit to the configured branch
- switching the connected branch in Pages and deploying again

## Post-Deployment Verification

After deployment, verify:

### Frontend

- landing page loads
- login/register flow works
- role selection works
- elderly and child pages render

### Network

In browser devtools, confirm the frontend uses:

```text
/api/chat
/api/tts
/api/kv
```

The browser should not expose:

- `AI_API_KEY`
- `TTS_API_KEY`

### Features

Verify at least:

- send one chat message successfully
- speech route responds when configured
- settings page loads model value
- community feed can load
- activities page can load

## Troubleshooting

### Chat returns 500

Usually means:

- `AI_API_KEY` is missing
- `AI_API_BASE_URL` is missing
- `AI_MODEL_NAME` is missing or invalid

### Chat returns 502

Usually means:

- upstream AI service is unavailable
- upstream returned an unexpected response

### KV-backed features fail

Check:

- `SILVER_KV` is bound
- binding exists in the active environment
- Pages Functions are actually deployed from the repo root

### Static site works but APIs do not

This usually means only `build/web` was uploaded and `functions/` was not deployed.

## Related Documentation

- [KV Storage Guide](kv-storage-guide.md)
