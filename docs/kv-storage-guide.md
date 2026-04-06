# KV Storage Guide

This document explains how KV-backed storage is used in the project, how it is deployed on Cloudflare Pages, and what to expect in local development and tests.

## Overview

The app uses Cloudflare KV for lightweight persisted state that should survive page refreshes and be available across sessions for the same demo identity.

Current KV-backed flows:

- Chat history
- User settings
- Community feed engagement state and newly published posts
- Elderly activities engagement state and newly published activities

The frontend does not talk to Cloudflare KV directly. It always goes through Pages Functions under `functions/api/`.

## Storage Architecture

### Frontend

The frontend reads and writes through service classes:

- `lib/services/kv_client.dart`
- `lib/services/settings_store.dart`
- `lib/features/chat/chat_controller.dart`
- `lib/features/community/community_feed_service.dart`
- `lib/features/elderly/elderly_activities_service.dart`
- `lib/services/demo_identity_store.dart`

### Backend

Cloudflare Pages Functions own the actual KV access:

- `functions/api/kv/[key].js`
- `functions/api/community.js`
- `functions/api/community/[postId]/respond.js`
- `functions/api/activities.js`
- `functions/api/activities/[activityId]/join.js`
- `functions/api/_lib/engagement_store.js`

## Key Naming Rules

### Per-identity keys

The app generates a demo identity and uses it to isolate user-specific data.

Examples:

- Chat history: `chat_history_<actorId>`
- Settings: `user_settings_<actorId>`

Where `<actorId>` comes from `DemoIdentityStore`.

This means different demo users do not overwrite each other inside the same KV namespace.

### Community and activities keys

Community and activity data use a small indexed storage model.

Examples:

- Item index: `<prefix>:index`
- Item payload: `<prefix>:item:<id>`
- User action marker: `<prefix>:action:<id>:<action>:<actorId>`

Concrete prefixes currently used:

- `community`
- `activities`

## Data Shapes

### Chat history

Stored value:

```json
{
  "messages": [
    {
      "role": "user",
      "content": "Hello",
      "createdAt": "2026-04-06T12:34:56.000Z"
    }
  ]
}
```

### Settings

Stored value:

```json
{
  "model": "openai/gpt-4o-mini"
}
```

### Community and activities

Community posts and activity records are stored as item JSON plus an index list. User-specific response/join state is stored separately via action markers so the backend can derive flags like:

- `respondedByMe`
- `joinedByMe`

## Fallback Behavior

### Settings

`SettingsStore` uses this order:

1. Remote KV
2. Local `SharedPreferences`
3. Build-time fallback default

### Chat history

`ChatController` tries to load chat history from KV using the current demo identity key. If KV is unavailable, chat still works for the current session.

### Community and activities

Community and activities services fall back to bundled mock data if the backend call fails.

## Cloudflare Deployment Requirements

You must bind a KV namespace to the Pages project using the variable name:

```text
SILVER_KV
```

Without this binding:

- Chat history sync will fail
- Settings sync will fail
- Community publish/respond will fail
- Activity publish/join will fail

Detailed setup steps are also documented in:

- `docs/cloudflare-pages-deployment.md`

## Local Development Notes

### Running locally without Pages bindings

In plain Flutter local runs, you may not have a working KV-backed backend. In that case:

- Settings may fall back to local preferences
- Chat may run without persisted remote history
- Community and activities may fall back to mock data

### Base path used by the frontend

`KvClient` defaults to:

```text
/api/kv
```

This can be overridden with the build-time environment value:

```text
AI_KV_URL
```

## Test Environment Notes

In Flutter widget tests, real HTTP is blocked by the test binding. Because of that, you may still see log lines like:

- `KV Get Error (400)`
- `KV Put Error (400)`

These logs are expected when a widget test touches code that would normally issue an HTTP request. They do not mean the test failed.

Where tests need deterministic KV behavior, they should inject a fake `KvClient` or a fake `DemoIdentityStore`.

## Troubleshooting

### Symptom: settings do not persist across refreshes

Check:

- `SILVER_KV` is bound in Pages
- the `functions/api/kv/[key].js` route is deployed
- the frontend is loading the same demo identity

### Symptom: chat works but old messages do not come back

Check:

- KV binding exists
- the generated `actorId` did not change
- `chat_history_<actorId>` is being written successfully

### Symptom: publish/respond/join fails in community or activities

Check:

- KV binding exists in both Preview and Production
- Pages Functions are deployed from the repo root
- the relevant function routes return 200/201 instead of 500

## Recommended Maintenance

When KV behavior changes, update all three places together:

1. `docs/kv-storage-guide.md`
2. `README.md`
3. `docs/cloudflare-pages-deployment.md`
