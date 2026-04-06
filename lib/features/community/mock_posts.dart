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
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    }
    return '${difference.inDays} d ago';
  }

  String get responseStatus {
    if (responseCount <= 0) {
      return 'Waiting for help';
    }
    return '$responseCount responses';
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
      username: json['username'] as String? ?? 'Neighbor',
      identity: json['identity'] as String? ?? 'Resident',
      tag: json['tag'] as String? ?? 'Help',
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
    username: 'Wang Ayi',
    identity: 'Building 3',
    tag: 'Help',
    title: 'Need help replacing a light bulb',
    location: 'Chaoyang District',
    summary: 'The light bulb at home is out and I need a neighbor to help.',
    createdAtEpochMs: 1774918200000,
    responseCount: 0,
  ),
  CommunityPost(
    id: 'seed-medicine-pickup',
    username: 'Li Shushu',
    identity: 'Volunteer',
    tag: 'Mutual aid',
    title: 'Medicine pickup on the way',
    location: 'Wangjing Street',
    summary: 'I am heading to the clinic this afternoon and can pick up medicine for neighbors.',
    createdAtEpochMs: 1774916700000,
    responseCount: 2,
    helperNames: <String>['Zhou Ayi', 'Chen Shifu'],
  ),
];
