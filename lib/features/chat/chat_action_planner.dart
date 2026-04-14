import 'dart:convert';

import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_publish_action.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_repository.dart';
import 'package:yinling_zhiban_demo/services/demo_identity_store.dart';

abstract class ChatActionPlanner {
  Future<ChatPublishIntent> analyze({
    required List<ChatMessage> history,
    required DemoIdentity identity,
    required String model,
    ChatPublishIntent? pendingIntent,
  });
}

class AiChatActionPlanner implements ChatActionPlanner {
  AiChatActionPlanner({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  final ChatRepository _repository;

  static const String _plannerSystemPrompt = '''
You are a structured action planner for a Chinese senior-care app.
Return exactly one JSON object and no markdown.

Schema:
{
  "action": "none|community_publish|activity_publish",
  "reply": "short Chinese reply for the user",
  "missingFields": ["field_key"],
  "communityDraft": {
    "username": "",
    "identity": "",
    "tag": "",
    "title": "",
    "location": "",
    "summary": ""
  },
  "activityDraft": {
    "organizerName": "",
    "title": "",
    "location": "",
    "description": "",
    "tag": "",
    "time": "",
    "group": "today|weekly"
  }
}

Rules:
- Use action "none" for normal chat or if the user is not trying to create or publish something.
- Supported publish actions:
  1. community_publish: a community mutual-help/help-request post.
  2. activity_publish: a community activity.
- reply must be concise Chinese. If fields are missing, ask only for the missing fields. If everything is ready, say the draft is ready and ask the user to confirm publication.
- Preserve already collected draft fields and update them when the user edits details.
- Do not invent title, location, time, or description if the user did not provide them.
- You may default missing community username and identity from the provided identity context.
- You may default missing activity organizerName from the provided identity context.
- Community default tag should be "互助" unless the text clearly indicates "求助".
- Activity default tag should be "社区活动".
- group must be "today" only when the time is clearly today; otherwise use "weekly".
- If action is "none", reply should be an empty string and both drafts should be null.
''';

  @override
  Future<ChatPublishIntent> analyze({
    required List<ChatMessage> history,
    required DemoIdentity identity,
    required String model,
    ChatPublishIntent? pendingIntent,
  }) async {
    final payload = <String, dynamic>{
      'identity': <String, dynamic>{
        'displayName': identity.displayName,
        'identityLabel': identity.identityLabel,
      },
      'pendingIntent': pendingIntent?.toJson(),
      'conversation': _serializeHistory(history),
    };

    final raw = await _repository.sendMessage(
      model: model,
      messages: <Map<String, String>>[
        const <String, String>{
          'role': 'system',
          'content': _plannerSystemPrompt,
        },
        <String, String>{
          'role': 'user',
          'content': jsonEncode(payload),
        },
      ],
    );

    final decoded = jsonDecode(_extractJsonObject(raw));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Planner JSON must be an object');
    }
    return ChatPublishIntent.fromJson(decoded);
  }

  List<Map<String, String>> _serializeHistory(List<ChatMessage> history) {
    final start = history.length > 10 ? history.length - 10 : 0;
    return history.sublist(start).map((message) {
      final role = switch (message.role) {
        ChatRole.user => 'user',
        ChatRole.assistant => 'assistant',
        ChatRole.system => 'system',
      };
      return <String, String>{
        'role': role,
        'content': message.content,
      };
    }).toList(growable: false);
  }

  String _extractJsonObject(String raw) {
    final trimmed = raw.trim();
    final fenceStart = trimmed.indexOf('{');
    final fenceEnd = trimmed.lastIndexOf('}');
    if (fenceStart == -1 || fenceEnd == -1 || fenceEnd <= fenceStart) {
      throw const FormatException('Planner response does not contain JSON');
    }
    return trimmed.substring(fenceStart, fenceEnd + 1);
  }
}
