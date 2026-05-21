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

const activitySeedItems = [
  {
    id: 'seed-morning-exercise',
    time: '10:00',
    title: '晨间舒缓操',
    location: '社区活动室 A 区',
    description: '由社区志愿者带领进行轻强度活动，适合晨间舒展。',
    tag: '轻运动',
    organizerName: '春和社区服务站',
    group: 'today',
    joinedCount: 4,
    participantNames: ['赵阿姨', '吴叔叔'],
    createdAtEpochMs: 1774922400000,
  },
  {
    id: 'seed-phone-help',
    time: '15:00',
    title: '智能手机答疑角',
    location: '服务站一楼咨询台',
    description: '解答手机使用、扫码和防诈识别等常见问题。',
    tag: '便民服务',
    organizerName: '社区数字志愿者',
    group: 'today',
    joinedCount: 2,
    participantNames: ['周奶奶'],
    createdAtEpochMs: 1774922400000,
  },
  {
    id: 'seed-choir',
    time: '周六 09:30',
    title: '邻里合唱练习',
    location: '社区文化礼堂',
    description: '欢迎结伴参加，现场有志愿者协助签到。',
    tag: '文娱',
    organizerName: '社区合唱团',
    group: 'weekly',
    joinedCount: 6,
    participantNames: ['陈阿姨', '李阿姨'],
    createdAtEpochMs: 1775266200000,
  },
  {
    id: 'seed-health-clinic',
    time: '周日 14:00',
    title: '健康义诊咨询',
    location: '社区卫生服务中心',
    description: '提供基础血压血糖咨询，请携带医保卡。',
    tag: '健康',
    organizerName: '社区卫生服务中心',
    group: 'weekly',
    joinedCount: 3,
    participantNames: ['王叔叔'],
    createdAtEpochMs: 1775266200000,
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
    const items = await loadItems(context.env.SILVER_KV, 'activities', activitySeedItems);
    items.sort((left, right) => (right.createdAtEpochMs ?? 0) - (left.createdAtEpochMs ?? 0));
    const joinedKeys = actorId
      ? await Promise.all(
          items.map((item) =>
            getJson(
              context.env.SILVER_KV,
              actionKey('activities', item.id, 'join', actorId),
            ),
          ),
        )
      : [];
    return jsonResponse({
      items: items.map((item, index) => ({
        ...item,
        joinedByMe: actorId ? joinedKeys[index] !== null : false,
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
  const organizerName = cleanString(body.organizerName, { maxLength: 40 });
  const title = cleanString(body.title, { maxLength: 80 });
  const location = cleanString(body.location, { maxLength: 80 });
  const description = cleanString(body.description, { maxLength: 240 });
  const tag = cleanString(body.tag, { maxLength: 20, fallback: '社区活动' });
  const time = cleanString(body.time, { maxLength: 40 });
  const group = cleanString(body.group, {
    maxLength: 20,
    fallback: 'weekly',
  });

  if (!actorId || !organizerName || !title || !location || !description || !time) {
    return jsonResponse({ error: 'Missing required activity fields' }, 400);
  }

  const item = {
    id: crypto.randomUUID(),
    organizerName,
    title,
    location,
    description,
    tag,
    time,
    organizerActorId: actorId,
    group: group === 'today' ? 'today' : 'weekly',
    joinedCount: 0,
    participantNames: [],
    createdAtEpochMs: Date.now(),
  };
  try {
    await saveItem(context.env.SILVER_KV, 'activities', item);
    await prependItemId(context.env.SILVER_KV, 'activities', item.id);
  } catch (_) {
    return jsonResponse({ error: 'Failed to persist activity to KV' }, 500);
  }

  return jsonResponse({ item: { ...item, joinedByMe: false } }, 201);
}
