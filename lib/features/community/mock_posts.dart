enum CommunityFeedBucket { recommended, latest }

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.username,
    required this.identity,
    required this.tag,
    required this.title,
    required this.location,
    required this.summary,
    required this.createdAtEpochMs,
    this.ownerActorId = '',
    this.responseCount = 0,
    this.helperNames = const <String>[],
    this.respondedByMe = false,
  });

  final String id;
  final String username;
  final String identity;
  final String tag;
  final String title;
  final String location;
  final String summary;
  final int createdAtEpochMs;
  final String ownerActorId;
  final int responseCount;
  final List<String> helperNames;
  final bool respondedByMe;

  String get time {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtEpochMs);
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) {
       return '刚刚';
    }
    if (difference.inHours < 1) {
       return '${difference.inMinutes} 分钟前';
    }
    if (difference.inDays < 1) {
       return '${difference.inHours} 小时前';
    }
     return '${difference.inDays} 天前';
  }

  String get responseStatus {
    if (responseCount <= 0) {
       return '等待帮助';
    }
     return '$responseCount 人响应';
  }

  CommunityPost copyWith({
    String? id,
    String? username,
    String? identity,
    String? tag,
    String? title,
    String? location,
    String? summary,
    int? createdAtEpochMs,
    String? ownerActorId,
    int? responseCount,
    List<String>? helperNames,
    bool? respondedByMe,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      username: username ?? this.username,
      identity: identity ?? this.identity,
      tag: tag ?? this.tag,
      title: title ?? this.title,
      location: location ?? this.location,
      summary: summary ?? this.summary,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      ownerActorId: ownerActorId ?? this.ownerActorId,
      responseCount: responseCount ?? this.responseCount,
      helperNames: helperNames ?? this.helperNames,
      respondedByMe: respondedByMe ?? this.respondedByMe,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'identity': identity,
      'tag': tag,
      'title': title,
      'location': location,
      'summary': summary,
      'createdAtEpochMs': createdAtEpochMs,
      'ownerActorId': ownerActorId,
      'responseCount': responseCount,
      'helperNames': helperNames,
      'respondedByMe': respondedByMe,
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final helpers = json['helperNames'];
    return CommunityPost(
      id: json['id'] as String? ?? '',
       username: json['username'] as String? ?? '邻里用户',
       identity: json['identity'] as String? ?? '社区居民',
       tag: json['tag'] as String? ?? '求助',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      createdAtEpochMs: json['createdAtEpochMs'] is int
          ? json['createdAtEpochMs'] as int
          : int.tryParse('${json['createdAtEpochMs']}') ??
              DateTime.now().millisecondsSinceEpoch,
      ownerActorId: json['ownerActorId'] as String? ?? '',
      responseCount: json['responseCount'] is int
          ? json['responseCount'] as int
          : int.tryParse('${json['responseCount']}') ?? 0,
      helperNames: helpers is List
          ? helpers.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
      respondedByMe: json['respondedByMe'] == true,
    );
  }
}

const List<CommunityPost> mockPosts = <CommunityPost>[
  CommunityPost(
    id: 'seed-help-light-bulb',
     username: '王阿姨',
     identity: '3号楼住户',
     tag: '求助',
     title: '家里灯泡坏了，想请人帮忙更换',
     location: '朝阳区春和社区',
     summary: '家中客厅灯泡损坏，希望有邻居可以上门协助更换。',
    createdAtEpochMs: 1774918200000,
    responseCount: 0,
  ),
  CommunityPost(
    id: 'seed-medicine-pickup',
     username: '李叔叔',
     identity: '社区志愿者',
     tag: '互助',
     title: '下午去社区诊所，可帮邻居代取药',
     location: '望京街道',
     summary: '今天下午前往诊所办理事务，可顺路帮邻居代取药品。',
    createdAtEpochMs: 1774916700000,
    responseCount: 2,
     helperNames: <String>['周阿姨', '陈师傅'],
  ),
];
