export function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  });
}

export function requireKv(context) {
  if (!context.env.SILVER_KV) {
    return jsonResponse({ error: 'KV namespace SILVER_KV is not bound' }, 500);
  }
  return null;
}

export async function parseJsonBody(request) {
  try {
    const body = await request.json();
    if (!body || typeof body !== 'object' || Array.isArray(body)) {
      return { error: jsonResponse({ error: 'Request body must be a JSON object' }, 400) };
    }
    return { body };
  } catch (_) {
    return { error: jsonResponse({ error: 'Request body must be valid JSON' }, 400) };
  }
}

export function cleanString(value, { maxLength = 120, fallback = '' } = {}) {
  if (typeof value !== 'string') {
    return fallback;
  }
  const cleaned = value.trim();
  if (!cleaned) {
    return fallback;
  }
  return cleaned.slice(0, maxLength);
}

export function itemKey(prefix, id) {
  return `${prefix}:item:${id}`;
}

function indexKey(prefix) {
  return `${prefix}:index`;
}

export function actionKey(prefix, id, action, actorId) {
  return `${prefix}:action:${id}:${action}:${actorId}`;
}

export async function getJson(kv, key) {
  const raw = await kv.get(key, { type: 'text' });
  if (raw === null) {
    return null;
  }
  try {
    return JSON.parse(raw);
  } catch (_) {
    return null;
  }
}

export async function putJson(kv, key, value) {
  await kv.put(key, JSON.stringify(value));
}

export async function ensureSeedItems(kv, prefix, items) {
  const existingIndex = await getJson(kv, indexKey(prefix));
  if (existingIndex && Array.isArray(existingIndex.ids) && existingIndex.ids.length > 0) {
    return existingIndex.ids;
  }

  const ids = [];
  for (const item of items) {
    ids.push(item.id);
    await putJson(kv, itemKey(prefix, item.id), item);
  }
  await putJson(kv, indexKey(prefix), { ids });
  return ids;
}

export async function loadItems(kv, prefix, seedItems = []) {
  let index = await getJson(kv, indexKey(prefix));
  if (!index || !Array.isArray(index.ids) || index.ids.length === 0) {
    if (seedItems.length === 0) {
      return [];
    }
    await ensureSeedItems(kv, prefix, seedItems);
    index = await getJson(kv, indexKey(prefix));
  }

  const items = [];
  for (const id of index.ids) {
    if (typeof id !== 'string' || id.length === 0) {
      continue;
    }
    const item = await getJson(kv, itemKey(prefix, id));
    if (item) {
      items.push(item);
    }
  }
  return items;
}

export async function prependItemId(kv, prefix, id, maxIds = 120) {
  const index = (await getJson(kv, indexKey(prefix))) ?? { ids: [] };
  const existingIds = Array.isArray(index.ids) ? index.ids.filter((item) => typeof item === 'string') : [];
  const nextIds = [id, ...existingIds.filter((item) => item !== id)].slice(0, maxIds);
  await putJson(kv, indexKey(prefix), { ids: nextIds });
}

export async function loadItem(kv, prefix, id) {
  return getJson(kv, itemKey(prefix, id));
}

export async function saveItem(kv, prefix, item) {
  await putJson(kv, itemKey(prefix, item.id), item);
}
