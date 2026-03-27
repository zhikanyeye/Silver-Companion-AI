function jsonResponse(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  });
}

function joinSpeechUrl(baseUrl) {
  return `${baseUrl.replace(/\/+$/, '')}/v1/audio/speech`;
}

export async function onRequest(context) {
  if (context.request.method !== 'POST') {
    return jsonResponse({error: 'Method not allowed'}, 405);
  }

  const apiKey = context.env?.TTS_API_KEY?.trim() ?? '';
  const baseUrl = context.env?.TTS_API_BASE_URL?.trim() ?? '';

  if (!baseUrl) {
    return jsonResponse({error: 'TTS service URL is not configured (TTS_API_BASE_URL)'}, 500);
  }

  let requestBody;
  try {
    requestBody = await context.request.json();
  } catch (_) {
    return jsonResponse({error: 'Request body must be valid JSON'}, 400);
  }

  if (!requestBody || typeof requestBody !== 'object' || Array.isArray(requestBody)) {
    return jsonResponse({error: 'Request body must be a JSON object'}, 400);
  }

  const headers = {
    'content-type': 'application/json',
  };

  // Add EdgeTTS bearer token if configured
  if (apiKey) {
    headers['authorization'] = `Bearer ${apiKey}`;
  }

  let upstreamResponse;
  try {
    upstreamResponse = await fetch(joinSpeechUrl(baseUrl), {
      method: 'POST',
      headers: headers,
      body: JSON.stringify(requestBody),
    });
  } catch (_) {
    return jsonResponse({error: 'Failed to reach TTS service upstream'}, 502);
  }

  // EdgeTTS returns audio bytes when successful, not JSON.
  // Directly stream the response back.
  return new Response(upstreamResponse.body, {
    status: upstreamResponse.status,
    headers: {
      'content-type': upstreamResponse.headers.get('content-type') || 'audio/mpeg',
      // Allow browsers to handle length
      ...(upstreamResponse.headers.has('content-length') && {
        'content-length': upstreamResponse.headers.get('content-length'),
      }),
    },
  });
}
