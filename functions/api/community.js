import {
  actionKey,
  cleanString,
  getJson,
  jsonResponse,
  loadItems,
  parseJsonBody,
  prependItemId,
  requireKv,
  saveItem,
} from './_lib/engagement_store.js';

const communitySeedPosts = [
  {
    id: 'seed-help-light-bulb',
    username: '王阿姨',
    identity: '3号楼住户',
    tag: '求助',
    title: '3号楼灯泡更换求助',
    location: '朝阳区',
    summary: '家里灯泡坏了，希望有邻居方便时帮忙看一下。',
    createdAtEpochMs: 1774918200000,
    responseCount: 0,
    helperNames: [],
  },
  {
    id: 'seed-medicine-pickup',
    username: '李叔叔',
    identity: '社区志愿者',
    tag: '互助',
    title: '代取药顺路互助',
    location: '望京街道',
    summary: '下午去社区卫生服务中心取药，可顺路帮邻居代领常用药。',
    createdAtEpochMs: 1774916700000,
    responseCount: 2,
    helperNames: ['周阿姨', '陈师傅'],
  },
];

export async function onRequest(context) {
  const kvError = requireKv(context);
  if (kvError) {
    return kvError;
  }

  if (context.request.method === 'GET') {
    const actorId = cleanString(
      new URL(context.request.url).searchParams.get('actorId'),
      { maxLength: 80 },
    );
    const items = await loadItems(context.env.SILVER_KV, 'community', communitySeedPosts);
    items.sort((left, right) => (right.createdAtEpochMs ?? 0) - (left.createdAtEpochMs ?? 0));
    const responseKeys = actorId
      ? await Promise.all(
          items.map((item) =>
            getJson(
              context.env.SILVER_KV,
              actionKey('community', item.id, 'respond', actorId),
            ),
          ),
        )
      : [];
    return jsonResponse({
      items: items.map((item, index) => ({
        ...item,
        respondedByMe: actorId ? responseKeys[index] !== null : false,
      })),
    });
  }

  if (context.request.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  const { body, error } = await parseJsonBody(context.request);
  if (error) {
    return error;
  }

  const actorId = cleanString(body.actorId, { maxLength: 80 });
  const username = cleanString(body.username, { maxLength: 40 });
  const identity = cleanString(body.identity, { maxLength: 40, fallback: '社区住户' });
  const tag = cleanString(body.tag, { maxLength: 20, fallback: '求助' });
  const title = cleanString(body.title, { maxLength: 80 });
  const location = cleanString(body.location, { maxLength: 60 });
  const summary = cleanString(body.summary, { maxLength: 240 });

  if (!actorId || !username || !title || !location || !summary) {
    return jsonResponse({ error: 'Missing required community post fields' }, 400);
  }

  const item = {
    id: crypto.randomUUID(),
    username,
    identity,
    tag,
    title,
    location,
    summary,
    ownerActorId: actorId,
    createdAtEpochMs: Date.now(),
    responseCount: 0,
    helperNames: [],
  };
  await saveItem(context.env.SILVER_KV, 'community', item);
  await prependItemId(context.env.SILVER_KV, 'community', item.id);

  return jsonResponse({ item: { ...item, respondedByMe: false } }, 201);
}
