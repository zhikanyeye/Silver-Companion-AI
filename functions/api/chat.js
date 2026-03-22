function jsonResponse(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  });
}

function joinChatCompletionsUrl(baseUrl) {
  return `${baseUrl.replace(/\/+$/, '')}/chat/completions`;
}

export async function onRequest(context) {
  if (context.request.method !== 'POST') {
    return jsonResponse({error: 'Method not allowed'}, 405);
  }

  const apiKey = context.env?.AI_API_KEY?.trim() ?? '';
  const defaultModel = context.env?.AI_MODEL_NAME?.trim() ?? '';
  const baseUrl = context.env?.AI_API_BASE_URL?.trim() ?? '';

  if (!apiKey || !baseUrl) {
    return jsonResponse({error: 'AI service is not configured'}, 500);
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

  const requestedModel =
    typeof requestBody.model === 'string' ? requestBody.model.trim() : '';
  const model = defaultModel || requestedModel;

  if (!model) {
    return jsonResponse({error: 'AI model is not configured'}, 500);
  }

  let upstreamResponse;
  try {
    upstreamResponse = await fetch(joinChatCompletionsUrl(baseUrl), {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({...requestBody, model}),
    });
  } catch (_) {
    return jsonResponse({error: 'Failed to reach AI service'}, 502);
  }

  let responseBody;
  try {
    responseBody = await upstreamResponse.json();
  } catch (_) {
    return jsonResponse({error: 'AI service returned invalid JSON'}, 502);
  }

  return jsonResponse(responseBody, upstreamResponse.status);
}
