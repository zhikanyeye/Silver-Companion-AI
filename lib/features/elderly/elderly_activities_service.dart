import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yinling/features/elderly/mock_service_data.dart';
import 'package:yinling/services/demo_identity_store.dart';

class ElderlyActivitiesService {
  ElderlyActivitiesService({
    http.Client? client,
    DemoIdentityStore? identityStore,
    this.basePath = '/api/activities',
  }) : _client = client ?? http.Client(),
       _identityStore = identityStore ?? DemoIdentityStore();

  final http.Client _client;
  final DemoIdentityStore _identityStore;
  final String basePath;

  Future<DemoIdentity> loadIdentity() => _identityStore.loadOrCreate();

  Uri _buildUri([String suffix = '']) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final configured = Uri.parse('$normalizedBase$suffix');
    if (configured.hasScheme) {
      return configured;
    }
    return Uri.base.resolveUri(configured);
  }

  Future<List<ElderlyActivityItem>> loadActivities() async {
    try {
      final identity = await loadIdentity();
      final response = await _client.get(
        _buildUri('?actorId=${Uri.encodeQueryComponent(identity.actorId)}'),
      );
      if (response.statusCode != 200) {
        return _fallbackActivities;
      }
      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) {
        return _fallbackActivities;
      }
      final items = payload['items'];
      if (items is! List) {
        return _fallbackActivities;
      }
      return items
          .whereType<Map>()
          .map(
            (item) => ElderlyActivityItem.fromJson(
              item.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return _fallbackActivities;
    }
  }

  Future<ElderlyActivityItem> publishActivity({
    required String organizerName,
    required String title,
    required String location,
    required String description,
    required String tag,
    required String time,
    required ElderlyActivityGroup group,
  }) async {
    final demoIdentity = await loadIdentity();
    final payload = <String, dynamic>{
      'actorId': demoIdentity.actorId,
      'organizerName': organizerName.trim(),
      'title': title.trim(),
      'location': location.trim(),
      'description': description.trim(),
      'tag': tag.trim(),
      'time': time.trim(),
      'group': group.name,
    };
    final response = await _client.post(
      _buildUri(),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw StateError('Activity publish failed: ${response.statusCode}');
    }

    await _identityStore.save(
      demoIdentity.copyWith(displayName: payload['organizerName'] as String),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ElderlyActivityItem.fromJson(
      (json['item'] as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }

  Future<ElderlyActivityItem> joinActivity(String activityId) async {
    final identity = await loadIdentity();
    final response = await _client.post(
      _buildUri('/$activityId/join'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'actorId': identity.actorId,
        'actorName': identity.displayName,
      }),
    );
    if (response.statusCode != 200) {
      throw StateError('Activity join failed: ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ElderlyActivityItem.fromJson(
      (json['item'] as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }

  List<ElderlyActivityItem> get _fallbackActivities => <ElderlyActivityItem>[
    ...todayRecommendedActivities,
    ...weeklyActivities,
  ];
}
