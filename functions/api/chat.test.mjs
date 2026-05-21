import test from 'node:test';
import assert from 'node:assert/strict';

import {onRequest} from './chat.js';

function createContext({env, body, fetchImpl}) {
  return {
    env,
    request: new Request('https://example.com/api/chat', {
      method: 'POST',
      headers: {'content-type': 'application/json'},
      body: JSON.stringify(body),
    }),
  };
}

test('uses configured env model instead of request body model', async () => {
  let forwardedBody;
  globalThis.fetch = async (_url, options) => {
    forwardedBody = JSON.parse(options.body);
    return new Response(
      JSON.stringify({choices: [{message: {content: 'ok'}}]}),
      {status: 200, headers: {'content-type': 'application/json'}},
    );
  };

  const response = await onRequest(
    createContext({
      env: {
        AI_API_KEY: 'secret',
        AI_API_BASE_URL: 'https://apis.iflow.cn/v1',
        AI_MODEL_NAME: 'qwen3-max',
      },
      body: {model: 'openai/gpt-4o-mini', messages: [{role: 'user', content: 'hi'}]},
    }),
  );

  assert.equal(response.status, 200);
  assert.equal(forwardedBody.model, 'qwen3-max');
});

test('falls back to request body model when env model is absent', async () => {
  let forwardedBody;
  globalThis.fetch = async (_url, options) => {
    forwardedBody = JSON.parse(options.body);
    return new Response(
      JSON.stringify({choices: [{message: {content: 'ok'}}]}),
      {status: 200, headers: {'content-type': 'application/json'}},
    );
  };

  const response = await onRequest(
    createContext({
      env: {
        AI_API_KEY: 'secret',
        AI_API_BASE_URL: 'https://apis.iflow.cn/v1',
        AI_MODEL_NAME: '',
      },
      body: {model: 'qwen3-max', messages: [{role: 'user', content: 'hi'}]},
    }),
  );

  assert.equal(response.status, 200);
  assert.equal(forwardedBody.model, 'qwen3-max');
});

test('returns readable upstream error details for non-2xx responses', async () => {
  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({error: {message: 'invalid api key'}}),
      {status: 401, headers: {'content-type': 'application/json'}},
    );

  const response = await onRequest(
    createContext({
      env: {
        AI_API_KEY: 'bad-secret',
        AI_API_BASE_URL: 'https://apis.iflow.cn/v1',
        AI_MODEL_NAME: 'qwen3-max',
      },
      body: {messages: [{role: 'user', content: 'hi'}]},
    }),
  );

  assert.equal(response.status, 401);
  const payload = await response.json();
  assert.deepEqual(payload, {
    error: 'invalid api key',
    errorType: 'upstream_error',
    upstreamStatus: 401,
  });
});

test('returns status for non-json upstream errors', async () => {
  globalThis.fetch = async () =>
    new Response('gateway error', {
      status: 502,
      headers: {'content-type': 'text/plain'},
    });

  const response = await onRequest(
    createContext({
      env: {
        AI_API_KEY: 'secret',
        AI_API_BASE_URL: 'https://apis.iflow.cn/v1',
        AI_MODEL_NAME: 'qwen3-max',
      },
      body: {messages: [{role: 'user', content: 'hi'}]},
    }),
  );

  assert.equal(response.status, 502);
  const payload = await response.json();
  assert.deepEqual(payload, {
    error: 'AI service returned a non-JSON error',
    errorType: 'upstream_error',
    upstreamStatus: 502,
  });
});

test('marks missing base url as configuration error', async () => {
  const response = await onRequest(
    createContext({
      env: {
        AI_API_KEY: 'secret',
        AI_API_BASE_URL: '',
        AI_MODEL_NAME: 'qwen3-max',
      },
      body: {messages: [{role: 'user', content: 'hi'}]},
    }),
  );

  assert.equal(response.status, 500);
  const payload = await response.json();
  assert.deepEqual(payload, {
    error: 'AI service URL is not configured (AI_API_BASE_URL)',
    errorType: 'configuration',
  });
});
