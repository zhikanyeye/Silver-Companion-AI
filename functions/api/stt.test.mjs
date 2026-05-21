import test from 'node:test';
import assert from 'node:assert/strict';

import {onRequest} from './stt.js';

function createContext({env, formData}) {
  return {
    env,
    request: new Request('https://example.com/api/stt', {
      method: 'POST',
      body: formData,
    }),
  };
}

test('forwards multipart audio file to upstream transcription endpoint', async () => {
  let forwardedUrl;
  let forwardedOptions;

  globalThis.fetch = async (url, options) => {
    forwardedUrl = url;
    forwardedOptions = options;
    return new Response(JSON.stringify({text: '你好 世界'}), {
      status: 200,
      headers: {'content-type': 'application/json'},
    });
  };

  const formData = new FormData();
  formData.append('file', new File(['voice-bytes'], 'voice-input.webm', {type: 'audio/webm'}));

  const response = await onRequest(
    createContext({
      env: {
        STT_API_KEY: 'secret',
        STT_API_BASE_URL: 'https://api.openai.com/v1',
        STT_MODEL_NAME: 'gpt-4o-mini-transcribe',
      },
      formData,
    }),
  );

  assert.equal(response.status, 200);
  assert.equal(forwardedUrl, 'https://api.openai.com/v1/audio/transcriptions');
  assert.equal(forwardedOptions.method, 'POST');
  assert.equal(forwardedOptions.headers.authorization, 'Bearer secret');

  const upstreamForm = forwardedOptions.body;
  assert.equal(upstreamForm.get('model'), 'gpt-4o-mini-transcribe');
  assert.equal(upstreamForm.get('language'), 'zh');
  assert.equal(upstreamForm.get('response_format'), 'json');
  assert.equal(upstreamForm.get('file').name, 'voice-input.webm');

  const payload = await response.json();
  assert.deepEqual(payload, {text: '你好 世界'});
});

test('returns 400 when file is missing', async () => {
  const response = await onRequest(
    createContext({
      env: {
        STT_API_KEY: 'secret',
        STT_API_BASE_URL: 'https://api.openai.com/v1',
      },
      formData: new FormData(),
    }),
  );

  assert.equal(response.status, 400);
  const payload = await response.json();
  assert.equal(payload.error, 'Missing audio file');
});

test('flattens upstream object errors into a readable string', async () => {
  globalThis.fetch = async () =>
    new Response(JSON.stringify({error: {message: 'bad audio format'}}), {
      status: 400,
      headers: {'content-type': 'application/json'},
    });

  const formData = new FormData();
  formData.append('file', new File(['voice-bytes'], 'voice-input.webm', {type: 'audio/webm'}));

  const response = await onRequest(
    createContext({
      env: {
        STT_API_KEY: 'secret',
        STT_API_BASE_URL: 'https://api.openai.com/v1',
      },
      formData,
    }),
  );

  assert.equal(response.status, 400);
  const payload = await response.json();
  assert.equal(payload.error, 'bad audio format');
});

test('supports vosk provider by forwarding multipart audio to /transcribe', async () => {
  let forwardedUrl;
  let forwardedOptions;

  globalThis.fetch = async (url, options) => {
    forwardedUrl = url;
    forwardedOptions = options;
    return new Response(JSON.stringify({text: '今天天气不错'}), {
      status: 200,
      headers: {'content-type': 'application/json'},
    });
  };

  const formData = new FormData();
  formData.append('file', new File(['voice-bytes'], 'voice-input.webm', {type: 'audio/webm'}));

  const response = await onRequest(
    createContext({
      env: {
        STT_PROVIDER: 'vosk',
        STT_API_BASE_URL: 'https://vosk.example.com',
        STT_API_KEY: 'vosk-secret',
      },
      formData,
    }),
  );

  assert.equal(response.status, 200);
  assert.equal(forwardedUrl, 'https://vosk.example.com/transcribe');
  assert.equal(forwardedOptions.method, 'POST');
  assert.equal(forwardedOptions.headers.authorization, 'Bearer vosk-secret');
  assert.equal(forwardedOptions.body.get('language'), 'zh-CN');
  assert.equal(forwardedOptions.body.get('file').name, 'voice-input.webm');

  const payload = await response.json();
  assert.deepEqual(payload, {text: '今天天气不错'});
});

test('allows vosk provider without api key', async () => {
  globalThis.fetch = async () =>
    new Response(JSON.stringify({text: '无需密钥'}), {
      status: 200,
      headers: {'content-type': 'application/json'},
    });

  const formData = new FormData();
  formData.append('file', new File(['voice-bytes'], 'voice-input.webm', {type: 'audio/webm'}));

  const response = await onRequest(
    createContext({
      env: {
        STT_PROVIDER: 'vosk',
        STT_API_BASE_URL: 'https://vosk.example.com',
      },
      formData,
    }),
  );

  assert.equal(response.status, 200);
  const payload = await response.json();
  assert.deepEqual(payload, {text: '无需密钥'});
});
