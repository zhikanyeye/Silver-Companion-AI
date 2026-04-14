import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yinling/features/community/mock_posts.dart';
import 'package:yinling/services/demo_identity_store.dart';

class CommunityFeedService {
  CommunityFeedService({
    http.Client? client,
    DemoIdentityStore? identityStore,
    this.basePath = '/api/community',
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

  Future<List<CommunityPost>> loadPosts() async {
    try {
      final identity = await loadIdentity();
      final response = await _client.get(
        _buildUri('?actorId=${Uri.encodeQueryComponent(identity.actorId)}'),
      );
      if (response.statusCode != 200) {
        return mockPosts;
      }
      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) {
        return mockPosts;
      }
      final items = payload['items'];
      if (items is! List) {
        return mockPosts;
      }
      return items
          .whereType<Map>()
          .map(
            (item) => CommunityPost.fromJson(
              item.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return mockPosts;
    }
  }

  Future<CommunityPost> publishPost({
    required String username,
    required String identity,
    required String tag,
    required String title,
    required String location,
    required String summary,
  }) async {
    final demoIdentity = await loadIdentity();
    final payload = <String, dynamic>{
      'actorId': demoIdentity.actorId,
      'username': username.trim(),
      'identity': identity.trim(),
      'tag': tag.trim(),
      'title': title.trim(),
      'location': location.trim(),
      'summary': summary.trim(),
    };
    final response = await _client.post(
      _buildUri(),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw StateError('Community publish failed: ${response.statusCode}');
    }

    await _identityStore.save(
      demoIdentity.copyWith(
        displayName: payload['username'] as String,
        identityLabel: payload['identity'] as String,
      ),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CommunityPost.fromJson(
      (json['item'] as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }

  Future<CommunityPost> respondToPost(String postId) async {
    final identity = await loadIdentity();
    final response = await _client.post(
      _buildUri('/$postId/respond'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'actorId': identity.actorId,
        'actorName': identity.displayName,
      }),
    );
    if (response.statusCode != 200) {
      throw StateError('Community respond failed: ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CommunityPost.fromJson(
      (json['item'] as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }
}
