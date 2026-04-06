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
      organizerName: json['organizerName'] as String? ?? 'Community organizer',
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
    label: 'Family contact',
    name: 'Ms. Li',
    phone: '138-0000-0001',
    description: 'Reach family first to confirm the current situation.',
    icon: Icons.family_restroom_rounded,
  ),
  ElderlySupportContact(
    label: 'Community service',
    name: 'Chunhe Community Center',
    phone: '021-5600-1234',
    description: 'Ask about home visits, activities, and local services.',
    icon: Icons.home_work_outlined,
  ),
  ElderlySupportContact(
    label: 'Platform support',
    name: 'Silver Companion Support',
    phone: '400-860-8899',
    description: 'Use this line for product help or manual transfer.',
    icon: Icons.support_agent_rounded,
  ),
];

const List<ElderlyActivityItem> todayRecommendedActivities = <ElderlyActivityItem>[
  ElderlyActivityItem(
    id: 'seed-morning-exercise',
    time: '10:00',
    title: 'Morning stretching',
    location: 'Community Hall A',
    description: 'A light exercise session led by community volunteers.',
    tag: 'Exercise',
    organizerName: 'Chunhe Community Center',
    group: ElderlyActivityGroup.today,
    joinedCount: 4,
    participantNames: <String>['Zhao Ayi', 'Wu Shushu'],
    createdAtEpochMs: 1774922400000,
  ),
  ElderlyActivityItem(
    id: 'seed-phone-help',
    time: '15:00',
    title: 'Smartphone help desk',
    location: 'Service Desk, 1F',
    description: 'Get help with phones, scanning QR codes, and scam awareness.',
    tag: 'Service',
    organizerName: 'Digital Volunteers',
    group: ElderlyActivityGroup.today,
    joinedCount: 2,
    participantNames: <String>['Zhou Nainai'],
    createdAtEpochMs: 1774922400000,
  ),
];

const List<ElderlyActivityItem> weeklyActivities = <ElderlyActivityItem>[
  ElderlyActivityItem(
    id: 'seed-choir',
    time: 'Sat 09:30',
    title: 'Neighborhood choir',
    location: 'Community Culture Hall',
    description: 'Join the local choir rehearsal with volunteer sign-in support.',
    tag: 'Culture',
    organizerName: 'Community Choir',
    group: ElderlyActivityGroup.weekly,
    joinedCount: 6,
    participantNames: <String>['Chen Ayi', 'Li Ayi'],
    createdAtEpochMs: 1775266200000,
  ),
  ElderlyActivityItem(
    id: 'seed-health-clinic',
    time: 'Sun 14:00',
    title: 'Health consultation',
    location: 'Community Health Center',
    description: 'Basic blood pressure and blood sugar consultation.',
    tag: 'Health',
    organizerName: 'Community Health Center',
    group: ElderlyActivityGroup.weekly,
    joinedCount: 3,
    participantNames: <String>['Wang Shushu'],
    createdAtEpochMs: 1775266200000,
  ),
];
