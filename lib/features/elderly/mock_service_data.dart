import 'package:flutter/material.dart';

class ElderlySupportContact {
  const ElderlySupportContact({
    required this.label,
    required this.name,
    required this.phone,
    required this.description,
    required this.icon,
  });

  final String label;
  final String name;
  final String phone;
  final String description;
  final IconData icon;
}

class ElderlyActivityItem {
  const ElderlyActivityItem({
    required this.time,
    required this.title,
    required this.location,
    required this.description,
    required this.tag,
  });

  final String time;
  final String title;
  final String location;
  final String description;
  final String tag;
}

const List<ElderlySupportContact> elderlySupportContacts = [
  ElderlySupportContact(
    label: '家人联系人',
    name: '李女士',
    phone: '138-0000-0001',
    description: '优先联系家人，协助确认当前情况。',
    icon: Icons.family_restroom_rounded,
  ),
  ElderlySupportContact(
    label: '社区服务站',
    name: '春和社区服务站',
    phone: '021-5600-1234',
    description: '适合咨询上门协助、活动和便民服务。',
    icon: Icons.home_work_outlined,
  ),
  ElderlySupportContact(
    label: '平台客服',
    name: '银龄智伴客服',
    phone: '400-860-8899',
    description: '如需产品帮助或人工转接，可联系平台客服。',
    icon: Icons.support_agent_rounded,
  ),
];

const List<ElderlyActivityItem> todayRecommendedActivities = [
  ElderlyActivityItem(
    time: '10:00',
    title: '晨间舒缓操',
    location: '社区活动室 A 区',
    description: '由社区志愿者带领进行轻强度活动，适合晨间舒展。',
    tag: '轻运动',
  ),
  ElderlyActivityItem(
    time: '15:00',
    title: '智能手机答疑角',
    location: '服务站一楼咨询台',
    description: '解答手机使用、扫码和防诈识别等常见问题。',
    tag: '便民服务',
  ),
];

const List<ElderlyActivityItem> weeklyActivities = [
  ElderlyActivityItem(
    time: '周六 09:30',
    title: '邻里合唱练习',
    location: '社区文化礼堂',
    description: '欢迎结伴参加，现场有志愿者协助签到。',
    tag: '文娱',
  ),
  ElderlyActivityItem(
    time: '周日 14:00',
    title: '健康义诊咨询',
    location: '社区卫生服务中心',
    description: '提供基础血压血糖咨询，请携带医保卡。',
    tag: '健康',
  ),
];
