import {
  actionKey,
  cleanString,
  getJson,
  jsonResponse,
  loadItem,
  parseJsonBody,
  putJson,
  requireKv,
  saveItem,
} from '../../_lib/engagement_store.js';

export async function onRequest(context) {
  const kvError = requireKv(context);
  if (kvError) {
    return kvError;
  }

  if (context.request.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  const postId = cleanString(context.params.postId, { maxLength: 80 });
  if (!postId) {
    return jsonResponse({ error: 'Post id is required' }, 400);
  }

  const { body, error } = await parseJsonBody(context.request);
  if (error) {
    return error;
  }

  const actorId = cleanString(body.actorId, { maxLength: 80 });
  const actorName = cleanString(body.actorName, {
    maxLength: 40,
    fallback: '热心邻里',
  });
  if (!actorId) {
    return jsonResponse({ error: 'Actor id is required' }, 400);
  }

  const item = await loadItem(context.env.SILVER_KV, 'community', postId);
  if (!item) {
    return jsonResponse({ error: 'Community post not found' }, 404);
  }

  const responseKey = actionKey('community', postId, 'respond', actorId);
  const existing = await getJson(context.env.SILVER_KV, responseKey);
  if (existing) {
    return jsonResponse({
      item: {
        ...item,
        respondedByMe: true,
      },
      duplicate: true,
    });
  }

  const nextHelpers = [actorName, ...(item.helperNames ?? [])]
    .filter((value, index, array) => array.indexOf(value) === index)
    .slice(0, 5);
  const nextItem = {
    ...item,
    responseCount: (item.responseCount ?? 0) + 1,
    helperNames: nextHelpers,
  };

  await putJson(context.env.SILVER_KV, responseKey, {
    actorId,
    actorName,
    createdAtEpochMs: Date.now(),
  });
  await saveItem(context.env.SILVER_KV, 'community', nextItem);

  return jsonResponse({
    item: {
      ...nextItem,
      respondedByMe: true,
    },
  });
}
