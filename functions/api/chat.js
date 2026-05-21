function jsonResponse(body, status) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  });
}

function cleanBaseUrl(baseUrl) {
  return baseUrl.trim().replace(/\/+$/, '');
}

function inferApiMode(baseUrl, configuredMode) {
  const mode = configuredMode.trim().toLowerCase();
  if (['chat', 'chat_completions', 'chat-completions'].includes(mode)) {
    return 'chat';
  }
  if (['messages', 'anthropic'].includes(mode)) {
    return 'messages';
  }
  if (['responses', 'response'].includes(mode)) {
    return 'responses';
  }

  const clean = cleanBaseUrl(baseUrl).toLowerCase();
  if (clean.endsWith('/messages')) {
    return 'messages';
  }
  if (clean.endsWith('/responses')) {
    return 'responses';
  }
  return 'chat';
}

function resolveUpstreamUrl(baseUrl, mode) {
  const clean = cleanBaseUrl(baseUrl);
  if (/\/(chat\/completions|messages|responses)$/i.test(clean)) {
    return clean;
  }
  if (/\/v\d+$/i.test(clean)) {
    if (mode === 'messages') {
      return `${clean}/messages`;
    }
    if (mode === 'responses') {
      return `${clean}/responses`;
    }
    return `${clean}/chat/completions`;
  }
  if (mode === 'messages') {
    return `${clean}/v1/messages`;
  }
  if (mode === 'responses') {
    return `${clean}/v1/responses`;
  }
  return `${clean}/v1/chat/completions`;
}

function buildUpstreamHeaders({apiKey, authHeaderName, authScheme, mode, anthropicVersion}) {
  const headers = {
    'content-type': 'application/json',
  };

  if (mode === 'messages') {
    headers['anthropic-version'] = anthropicVersion || '2023-06-01';
  }

  if (apiKey) {
    if (mode === 'messages' && !authHeaderName) {
      headers['x-api-key'] = apiKey;
    } else {
      const headerName = authHeaderName || 'authorization';
      const scheme = authScheme || 'Bearer';
      headers[headerName] = scheme ? `${scheme} ${apiKey}` : apiKey;
    }
  }

  return headers;
}

function normalizeRequestMessages(messages) {
  if (!Array.isArray(messages)) {
    return null;
  }

  return messages
    .filter((message) => message && typeof message === 'object')
    .map((message) => ({
      role: typeof message.role === 'string' ? message.role : 'user',
      content: typeof message.content === 'string' ? message.content : '',
    }))
    .filter((message) => message.content.trim());
}

function splitSystemPrompt(messages) {
  const systemParts = [];
  const conversation = [];

  for (const message of messages) {
    if (message.role === 'system') {
      systemParts.push(message.content);
    } else {
      conversation.push({
        role: message.role === 'assistant' ? 'assistant' : 'user',
        content: message.content,
      });
    }
  }

  return {
    system: systemParts.join('\n\n'),
    messages: conversation,
  };
}

function toResponsesInput(messages) {
  return messages.map((message) => ({
    role: message.role === 'assistant' ? 'assistant' : message.role === 'system' ? 'system' : 'user',
    content: [
      {
        type: message.role === 'assistant' ? 'output_text' : 'input_text',
        text: message.content,
      },
    ],
  }));
}

function buildUpstreamBody({mode, requestBody, model, messages, maxTokens}) {
  if (mode === 'messages') {
    const split = splitSystemPrompt(messages);
    const body = {
      model,
      messages: split.messages,
      max_tokens: Number(requestBody.max_tokens || requestBody.maxTokens || maxTokens || 1024),
    };
    if (split.system) {
      body.system = split.system;
    }
    if (typeof requestBody.temperature === 'number') {
      body.temperature = requestBody.temperature;
    }
    return body;
  }

  if (mode === 'responses') {
    const body = {
      model,
      input: toResponsesInput(messages),
    };
    if (typeof requestBody.instructions === 'string') {
      body.instructions = requestBody.instructions;
    }
    if (typeof requestBody.temperature === 'number') {
      body.temperature = requestBody.temperature;
    }
    if (requestBody.max_output_tokens || requestBody.maxTokens || maxTokens) {
      body.max_output_tokens = Number(requestBody.max_output_tokens || requestBody.maxTokens || maxTokens);
    }
    return body;
  }

  return {...requestBody, model, messages};
}

function normalizeContentBlocks(content) {
  if (typeof content === 'string') {
    return content;
  }
  if (!Array.isArray(content)) {
    return '';
  }
  return content
    .map((block) => {
      if (typeof block === 'string') {
        return block;
      }
      if (!block || typeof block !== 'object') {
        return '';
      }
      if (typeof block.text === 'string') {
        return block.text;
      }
      if (typeof block.content === 'string') {
        return block.content;
      }
      return '';
    })
    .filter(Boolean)
    .join('');
}

function extractResponsesText(responseBody) {
  if (typeof responseBody.output_text === 'string') {
    return responseBody.output_text;
  }

  if (!Array.isArray(responseBody.output)) {
    return '';
  }

  return responseBody.output
    .flatMap((item) => Array.isArray(item?.content) ? item.content : [])
    .map((content) => {
      if (typeof content?.text === 'string') {
        return content.text;
      }
      if (typeof content?.content === 'string') {
        return content.content;
      }
      return '';
    })
    .filter(Boolean)
    .join('');
}

function asChatCompletionsResponse(content, originalBody = {}) {
  return {
    id: originalBody.id,
    model: originalBody.model,
    choices: [
      {
        message: {
          role: 'assistant',
          content,
        },
      },
    ],
  };
}

function normalizeChatResponse(responseBody, mode) {
  if (!responseBody || typeof responseBody !== 'object') {
    return null;
  }

  if (Array.isArray(responseBody.choices)) {
    return responseBody;
  }

  if (mode === 'messages') {
    const content = normalizeContentBlocks(responseBody.content);
    if (content) {
      return asChatCompletionsResponse(content, responseBody);
    }
  }

  if (mode === 'responses') {
    const content = extractResponsesText(responseBody);
    if (content) {
      return asChatCompletionsResponse(content, responseBody);
    }
  }

  if (typeof responseBody.content === 'string') {
    return asChatCompletionsResponse(responseBody.content, responseBody);
  }

  if (typeof responseBody.text === 'string') {
    return asChatCompletionsResponse(responseBody.text, responseBody);
  }

  if (typeof responseBody.reply === 'string') {
    return asChatCompletionsResponse(responseBody.reply, responseBody);
  }

  return responseBody;
}

export async function onRequest(context) {
  if (context.request.method !== 'POST') {
    return jsonResponse({error: 'Method not allowed'}, 405);
  }

  const env = context.env ?? {};
  const apiKey = env.AI_API_KEY?.trim() ?? '';
  const defaultModel = env.AI_MODEL_NAME?.trim() ?? '';
  const baseUrl = env.AI_API_BASE_URL?.trim() ?? '';
  const configuredMode = env.AI_API_MODE?.trim() ?? '';
  const authHeaderName = env.AI_AUTH_HEADER?.trim() ?? '';
  const authScheme = env.AI_AUTH_SCHEME?.trim() ?? 'Bearer';
  const anthropicVersion = env.AI_ANTHROPIC_VERSION?.trim() ?? '';
  const maxTokens = env.AI_MAX_TOKENS?.trim() ?? '';

  if (!baseUrl) {
    return jsonResponse({error: 'AI service URL is not configured (AI_API_BASE_URL)'}, 500);
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
  const messages = normalizeRequestMessages(requestBody.messages);
  const mode = inferApiMode(baseUrl, configuredMode);

  if (!model) {
    return jsonResponse({error: 'AI model is not configured'}, 500);
  }

  if (!messages || messages.length === 0) {
    return jsonResponse({error: 'Request body must include non-empty messages'}, 400);
  }

  let upstreamResponse;
  try {
    upstreamResponse = await fetch(resolveUpstreamUrl(baseUrl, mode), {
      method: 'POST',
      headers: buildUpstreamHeaders({apiKey, authHeaderName, authScheme, mode, anthropicVersion}),
      body: JSON.stringify(buildUpstreamBody({mode, requestBody, model, messages, maxTokens})),
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

  const normalizedResponse = normalizeChatResponse(responseBody, mode);
  if (!normalizedResponse) {
    return jsonResponse({error: 'AI service returned invalid response'}, 502);
  }

  return jsonResponse(normalizedResponse, upstreamResponse.status);
}
