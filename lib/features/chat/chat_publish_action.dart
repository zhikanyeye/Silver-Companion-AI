import 'package:yinling/features/elderly/mock_service_data.dart';
import 'package:yinling/services/demo_identity_store.dart';

enum ChatPublishTarget { community, activity }

class CommunityPublishDraft {
  const CommunityPublishDraft({
    this.username = '',
    this.identity = '',
    this.tag = '',
    this.title = '',
    this.location = '',
    this.summary = '',
  });

  final String username;
  final String identity;
  final String tag;
  final String title;
  final String location;
  final String summary;

  CommunityPublishDraft withDefaults(DemoIdentity identitySource) {
    return CommunityPublishDraft(
      username: username.trim().isEmpty
          ? identitySource.displayName
          : username.trim(),
      identity: identity.trim().isEmpty
          ? identitySource.identityLabel
          : identity.trim(),
      tag: tag.trim().isEmpty ? '互助' : tag.trim(),
      title: title.trim(),
      location: location.trim(),
      summary: summary.trim(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'identity': identity,
        'tag': tag,
        'title': title,
        'location': location,
        'summary': summary,
      };

  factory CommunityPublishDraft.fromJson(Map<String, dynamic> json) {
    return CommunityPublishDraft(
      username: json['username'] as String? ?? '',
      identity: json['identity'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
    );
  }
}

class ActivityPublishDraft {
  const ActivityPublishDraft({
    this.organizerName = '',
    this.title = '',
    this.location = '',
    this.description = '',
    this.tag = '',
    this.time = '',
    this.group = ElderlyActivityGroup.weekly,
  });

  final String organizerName;
  final String title;
  final String location;
  final String description;
  final String tag;
  final String time;
  final ElderlyActivityGroup group;

  ActivityPublishDraft withDefaults(DemoIdentity identitySource) {
    return ActivityPublishDraft(
      organizerName: organizerName.trim().isEmpty
          ? identitySource.displayName
          : organizerName.trim(),
      title: title.trim(),
      location: location.trim(),
      description: description.trim(),
      tag: tag.trim().isEmpty ? '社区活动' : tag.trim(),
      time: time.trim(),
      group: group,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'organizerName': organizerName,
        'title': title,
        'location': location,
        'description': description,
        'tag': tag,
        'time': time,
        'group': group.name,
      };

  factory ActivityPublishDraft.fromJson(Map<String, dynamic> json) {
    final groupName = json['group'] as String? ?? '';
    final group = ElderlyActivityGroup.values.firstWhere(
      (item) => item.name == groupName,
      orElse: () => ElderlyActivityGroup.weekly,
    );

    return ActivityPublishDraft(
      organizerName: json['organizerName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      time: json['time'] as String? ?? '',
      group: group,
    );
  }
}

class ChatPublishIntent {
  const ChatPublishIntent._({
    required this.target,
    required this.reply,
    required this.communityDraft,
    required this.activityDraft,
    required this.missingFields,
  });

  const ChatPublishIntent.none({this.reply = ''})
      : target = null,
        communityDraft = null,
        activityDraft = null,
        missingFields = const <String>[];

  final ChatPublishTarget? target;
  final String reply;
  final CommunityPublishDraft? communityDraft;
  final ActivityPublishDraft? activityDraft;
  final List<String> missingFields;

  bool get isPublishIntent => target != null;

  bool get isReadyForConfirmation {
    if (!isPublishIntent || missingFields.isNotEmpty) {
      return false;
    }
    return communityDraft != null || activityDraft != null;
  }

  String get actionName {
    return switch (target) {
      ChatPublishTarget.community => 'community_publish',
      ChatPublishTarget.activity => 'activity_publish',
      null => 'none',
    };
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'action': actionName,
        'reply': reply,
        'missingFields': missingFields,
        'communityDraft': communityDraft?.toJson(),
        'activityDraft': activityDraft?.toJson(),
      };

  factory ChatPublishIntent.community({
    required String reply,
    required CommunityPublishDraft? draft,
    List<String> missingFields = const <String>[],
  }) {
    return ChatPublishIntent._(
      target: ChatPublishTarget.community,
      reply: reply,
      communityDraft: draft,
      activityDraft: null,
      missingFields: missingFields,
    );
  }

  factory ChatPublishIntent.activity({
    required String reply,
    required ActivityPublishDraft? draft,
    List<String> missingFields = const <String>[],
  }) {
    return ChatPublishIntent._(
      target: ChatPublishTarget.activity,
      reply: reply,
      communityDraft: null,
      activityDraft: draft,
      missingFields: missingFields,
    );
  }

  factory ChatPublishIntent.fromJson(Map<String, dynamic> json) {
    final action = (json['action'] as String? ?? '').trim().toLowerCase();
    final reply = (json['reply'] as String? ?? '').trim();
    final missing = (json['missingFields'] is List)
        ? (json['missingFields'] as List)
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false)
        : const <String>[];

    final communityDraftJson = json['communityDraft'];
    final activityDraftJson = json['activityDraft'];

    return switch (action) {
      'community' || 'community_publish' => ChatPublishIntent.community(
          reply: reply,
          draft: communityDraftJson is Map<String, dynamic>
              ? CommunityPublishDraft.fromJson(communityDraftJson)
              : communityDraftJson is Map
                  ? CommunityPublishDraft.fromJson(
                      communityDraftJson.map(
                        (key, value) => MapEntry(key.toString(), value),
                      ),
                    )
                  : null,
          missingFields: missing,
        ),
      'activity' || 'activity_publish' => ChatPublishIntent.activity(
          reply: reply,
          draft: activityDraftJson is Map<String, dynamic>
              ? ActivityPublishDraft.fromJson(activityDraftJson)
              : activityDraftJson is Map
                  ? ActivityPublishDraft.fromJson(
                      activityDraftJson.map(
                        (key, value) => MapEntry(key.toString(), value),
                      ),
                    )
                  : null,
          missingFields: missing,
        ),
      _ => ChatPublishIntent.none(reply: reply),
    };
  }
}
