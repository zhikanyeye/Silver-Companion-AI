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

enum ElderlyActivityGroup { today, weekly }

class ElderlyActivityItem {
  const ElderlyActivityItem({
    required this.id,
    required this.time,
    required this.title,
    required this.location,
    required this.description,
    required this.tag,
    required this.organizerName,
    required this.group,
    this.organizerActorId = '',
    this.joinedCount = 0,
    this.participantNames = const <String>[],
    this.joinedByMe = false,
    this.createdAtEpochMs = 0,
  });

  final String id;
  final String time;
  final String title;
  final String location;
  final String description;
  final String tag;
  final String organizerName;
  final String organizerActorId;
  final ElderlyActivityGroup group;
  final int joinedCount;
  final List<String> participantNames;
  final bool joinedByMe;
  final int createdAtEpochMs;

  ElderlyActivityItem copyWith({
    String? id,
    String? time,
    String? title,
    String? location,
    String? description,
    String? tag,
    String? organizerName,
    String? organizerActorId,
    ElderlyActivityGroup? group,
    int? joinedCount,
    List<String>? participantNames,
    bool? joinedByMe,
    int? createdAtEpochMs,
  }) {
    return ElderlyActivityItem(
      id: id ?? this.id,
      time: time ?? this.time,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      organizerName: organizerName ?? this.organizerName,
      organizerActorId: organizerActorId ?? this.organizerActorId,
      group: group ?? this.group,
      joinedCount: joinedCount ?? this.joinedCount,
      participantNames: participantNames ?? this.participantNames,
      joinedByMe: joinedByMe ?? this.joinedByMe,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'time': time,
      'title': title,
      'location': location,
      'description': description,
      'tag': tag,
      'organizerName': organizerName,
      'organizerActorId': organizerActorId,
      'group': group.name,
      'joinedCount': joinedCount,
      'participantNames': participantNames,
      'joinedByMe': joinedByMe,
      'createdAtEpochMs': createdAtEpochMs,
    };
  }

  factory ElderlyActivityItem.fromJson(Map<String, dynamic> json) {
    final participants = json['participantNames'];
    final rawGroup = json['group'] as String? ?? ElderlyActivityGroup.weekly.name;
    final group = ElderlyActivityGroup.values.firstWhere(
      (item) => item.name == rawGroup,
      orElse: () => ElderlyActivityGroup.weekly,
    );

    return ElderlyActivityItem(
      id: json['id'] as String? ?? '',
      time: json['time'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
       organizerName: json['organizerName'] as String? ?? '社区组织者',
      organizerActorId: json['organizerActorId'] as String? ?? '',
      group: group,
      joinedCount: json['joinedCount'] is int
          ? json['joinedCount'] as int
          : int.tryParse('${json['joinedCount']}') ?? 0,
      participantNames: participants is List
          ? participants.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
      joinedByMe: json['joinedByMe'] == true,
      createdAtEpochMs: json['createdAtEpochMs'] is int
          ? json['createdAtEpochMs'] as int
          : int.tryParse('${json['createdAtEpochMs']}') ?? 0,
    );
  }
}

const List<ElderlySupportContact> elderlySupportContacts = <ElderlySupportContact>[
  ElderlySupportContact(
     label: '家人联系',
     name: '李女士',
    phone: '138-0000-0001',
     description: '建议先联系家人，确认当前情况。',
    icon: Icons.family_restroom_rounded,
  ),
  ElderlySupportContact(
     label: '社区服务',
     name: '春和社区服务中心',
    phone: '021-5600-1234',
     description: '可咨询上门探访、活动安排与便民服务。',
    icon: Icons.home_work_outlined,
  ),
  ElderlySupportContact(
     label: '平台客服',
     name: '银龄智伴客服',
    phone: '400-860-8899',
     description: '可用于产品咨询与人工转接。',
    icon: Icons.support_agent_rounded,
  ),
];

const List<ElderlyActivityItem> todayRecommendedActivities = <ElderlyActivityItem>[
  ElderlyActivityItem(
    id: 'seed-morning-exercise',
    time: '10:00',
     title: '晨间拉伸',
     location: '社区活动室 A',
     description: '由社区志愿者带领的轻运动活动。',
     tag: '运动',
     organizerName: '春和社区服务中心',
    group: ElderlyActivityGroup.today,
    joinedCount: 4,
    participantNames: <String>['Zhao Ayi', 'Wu Shushu'],
    createdAtEpochMs: 1774922400000,
  ),
  ElderlyActivityItem(
    id: 'seed-phone-help',
    time: '15:00',
     title: '智能手机帮办',
     location: '一层服务台',
     description: '协助手机使用、扫码操作和防诈骗知识讲解。',
     tag: '服务',
     organizerName: '数字志愿队',
    group: ElderlyActivityGroup.today,
    joinedCount: 2,
    participantNames: <String>['Zhou Nainai'],
    createdAtEpochMs: 1774922400000,
  ),
];

const List<ElderlyActivityItem> weeklyActivities = <ElderlyActivityItem>[
  ElderlyActivityItem(
    id: 'seed-choir',
     time: '周六 09:30',
     title: '邻里合唱团',
     location: '社区文化礼堂',
     description: '参与社区合唱排练，现场有志愿者协助签到。',
     tag: '文化',
     organizerName: '社区合唱团',
    group: ElderlyActivityGroup.weekly,
    joinedCount: 6,
    participantNames: <String>['Chen Ayi', 'Li Ayi'],
    createdAtEpochMs: 1775266200000,
  ),
  ElderlyActivityItem(
    id: 'seed-health-clinic',
     time: '周日 14:00',
     title: '健康咨询',
     location: '社区卫生服务站',
     description: '提供基础血压、血糖咨询服务。',
     tag: '健康',
     organizerName: '社区卫生服务站',
    group: ElderlyActivityGroup.weekly,
    joinedCount: 3,
    participantNames: <String>['Wang Shushu'],
    createdAtEpochMs: 1775266200000,
  ),
];
