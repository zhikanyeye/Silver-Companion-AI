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

  const activityId = cleanString(context.params.activityId, { maxLength: 80 });
  if (!activityId) {
    return jsonResponse({ error: 'Activity id is required' }, 400);
  }

  const { body, error } = await parseJsonBody(context.request);
  if (error) {
    return error;
  }

  const actorId = cleanString(body.actorId, { maxLength: 80 });
  const actorName = cleanString(body.actorName, {
    maxLength: 40,
    fallback: '社区伙伴',
  });
  if (!actorId) {
    return jsonResponse({ error: 'Actor id is required' }, 400);
  }

  const item = await loadItem(context.env.SILVER_KV, 'activities', activityId);
  if (!item) {
    return jsonResponse({ error: 'Activity not found' }, 404);
  }

  const joinKey = actionKey('activities', activityId, 'join', actorId);
  const existing = await getJson(context.env.SILVER_KV, joinKey);
  if (existing) {
    return jsonResponse({
      item: {
        ...item,
        joinedByMe: true,
      },
      duplicate: true,
    });
  }

  const nextParticipants = [actorName, ...(item.participantNames ?? [])]
    .filter((value, index, array) => array.indexOf(value) === index)
    .slice(0, 6);
  const nextItem = {
    ...item,
    joinedCount: (item.joinedCount ?? 0) + 1,
    participantNames: nextParticipants,
  };

  await putJson(context.env.SILVER_KV, joinKey, {
    actorId,
    actorName,
    createdAtEpochMs: Date.now(),
  });
  await saveItem(context.env.SILVER_KV, 'activities', nextItem);

  return jsonResponse({
    item: {
      ...nextItem,
      joinedByMe: true,
    },
  });
}
