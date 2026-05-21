function jsonResponse(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  });
}

function joinTranscriptionsUrl(baseUrl) {
  return `${baseUrl.replace(/\/+$/, '')}/audio/transcriptions`;
}

function joinVoskTranscribeUrl(baseUrl) {
  return `${baseUrl.replace(/\/+$/, '')}/transcribe`;
}

function resolveErrorMessage(value) {
  if (typeof value === 'string' && value.trim()) {
    return value.trim();
  }

  if (value && typeof value === 'object') {
    if (typeof value.message === 'string' && value.message.trim()) {
      return value.message.trim();
    }
    if (typeof value.error === 'string' && value.error.trim()) {
      return value.error.trim();
    }
  }

  return 'STT service returned invalid response';
}

function resolveProvider(env) {
  const provider = env?.STT_PROVIDER?.trim().toLowerCase() ?? '';
  return provider || 'openai';
}

async function parseRequestForm(request) {
  try {
    return await request.formData();
  } catch (_) {
    return null;
  }
}

function extractAudioFile(requestForm) {
  const file = requestForm.get('file');
  return file instanceof File ? file : null;
}

async function proxyToOpenAIStyleProvider({
  baseUrl,
  apiKey,
  model,
  file,
  promptValue,
  languageValue,
}) {
  const upstreamForm = new FormData();
  upstreamForm.append('file', file, file.name || 'voice-input.webm');
  upstreamForm.append('model', model);
  upstreamForm.append(
    'language',
    typeof languageValue === 'string' && languageValue.trim()
      ? languageValue.trim()
      : 'zh',
  );
  upstreamForm.append('response_format', 'json');
  if (typeof promptValue === 'string' && promptValue.trim()) {
    upstreamForm.append('prompt', promptValue.trim());
  }

  const upstreamResponse = await fetch(joinTranscriptionsUrl(baseUrl), {
    method: 'POST',
    headers: {
      authorization: `Bearer ${apiKey}`,
    },
    body: upstreamForm,
  });

  const responseBody = await upstreamResponse.json();
  if (typeof responseBody.text !== 'string') {
    return {
      ok: false,
      status: upstreamResponse.status >= 400 ? upstreamResponse.status : 502,
      body: {error: resolveErrorMessage(responseBody.error)},
    };
  }

  return {
    ok: true,
    status: upstreamResponse.status,
    body: {text: responseBody.text},
  };
}

async function proxyToVoskProvider({
  baseUrl,
  apiKey,
  file,
  promptValue,
  languageValue,
}) {
  const upstreamForm = new FormData();
  upstreamForm.append('file', file, file.name || 'voice-input.webm');
  upstreamForm.append(
    'language',
    typeof languageValue === 'string' && languageValue.trim()
      ? languageValue.trim()
      : 'zh-CN',
  );
  if (typeof promptValue === 'string' && promptValue.trim()) {
    upstreamForm.append('prompt', promptValue.trim());
  }

  const headers = {};
  if (apiKey) {
    headers.authorization = `Bearer ${apiKey}`;
  }

  const upstreamResponse = await fetch(joinVoskTranscribeUrl(baseUrl), {
    method: 'POST',
    headers,
    body: upstreamForm,
  });

  const responseBody = await upstreamResponse.json();
  if (typeof responseBody.text !== 'string') {
    return {
      ok: false,
      status: upstreamResponse.status >= 400 ? upstreamResponse.status : 502,
      body: {error: resolveErrorMessage(responseBody.error)},
    };
  }

  return {
    ok: true,
    status: upstreamResponse.status,
    body: {text: responseBody.text},
  };
}

async function proxyToCloudflareWorkersAIProvider({
  aiBinding,
  model,
  file,
}) {
  if (!aiBinding || typeof aiBinding.run !== 'function') {
    return {
      ok: false,
      status: 500,
      body: {error: 'Cloudflare Workers AI binding is not configured (AI)'},
    };
  }

  const audioBytes = [...new Uint8Array(await file.arrayBuffer())];
  const responseBody = await aiBinding.run(model || '@cf/openai/whisper', {
    audio: audioBytes,
  });

  if (typeof responseBody?.text !== 'string') {
    return {
      ok: false,
      status: 502,
      body: {error: resolveErrorMessage(responseBody?.error)},
    };
  }

  return {
    ok: true,
    status: 200,
    body: {text: responseBody.text},
  };
}

export async function onRequest(context) {
  if (context.request.method !== 'POST') {
    return jsonResponse({error: 'Method not allowed'}, 405);
  }

  const provider = resolveProvider(context.env);
  const apiKey =
    context.env?.STT_API_KEY?.trim() ?? context.env?.AI_API_KEY?.trim() ?? '';
  const baseUrl =
    context.env?.STT_API_BASE_URL?.trim() ??
    context.env?.AI_API_BASE_URL?.trim() ??
    '';
  const model =
    context.env?.STT_MODEL_NAME?.trim() ||
    (provider === 'cloudflare' || provider === 'workers-ai'
      ? '@cf/openai/whisper'
      : 'gpt-4o-mini-transcribe');

  if (provider === 'cloudflare' || provider === 'workers-ai') {
    if (!context.env?.AI || typeof context.env.AI.run !== 'function') {
      return jsonResponse(
        {error: 'Cloudflare Workers AI binding is not configured (AI)'},
        500,
      );
    }
  } else if (!baseUrl || (provider !== 'vosk' && !apiKey)) {
    return jsonResponse(
      {error: 'STT service is not configured (STT_API_KEY/STT_API_BASE_URL)'},
      500,
    );
  }

  const requestForm = await parseRequestForm(context.request);
  if (requestForm === null) {
    return jsonResponse({error: 'Request body must be multipart/form-data'}, 400);
  }

  const file = extractAudioFile(requestForm);
  if (file === null) {
    return jsonResponse({error: 'Missing audio file'}, 400);
  }

  const promptValue = requestForm.get('prompt');
  const languageValue = requestForm.get('language');

  let result;
  try {
    if (provider === 'cloudflare' || provider === 'workers-ai') {
      result = await proxyToCloudflareWorkersAIProvider({
        aiBinding: context.env.AI,
        model,
        file,
      });
    } else if (provider === 'vosk') {
      result = await proxyToVoskProvider({
        baseUrl,
        apiKey,
        file,
        promptValue,
        languageValue,
      });
    } else {
      result = await proxyToOpenAIStyleProvider({
        baseUrl,
        apiKey,
        model,
        file,
        promptValue,
        languageValue,
      });
    }
  } catch (_) {
    return jsonResponse({error: 'Failed to reach STT service upstream'}, 502);
  }

  if (!result || typeof result !== 'object') {
    return jsonResponse({error: 'STT service returned invalid JSON'}, 502);
  }

  return jsonResponse(result.body, result.status);
}
