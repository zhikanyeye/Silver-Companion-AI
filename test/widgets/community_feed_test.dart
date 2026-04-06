import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling_zhiban_demo/features/community/community_feed_page.dart';
import 'package:yinling_zhiban_demo/features/community/community_feed_service.dart';
import 'package:yinling_zhiban_demo/features/community/mock_posts.dart';

class _FakeCommunityFeedService extends CommunityFeedService {
  static const actorId = 'guest-test-community';

  _FakeCommunityFeedService(List<CommunityPost> items)
    : _items = List<CommunityPost>.from(items);

  final List<CommunityPost> _items;

  @override
  Future<List<CommunityPost>> loadPosts() async {
    return List<CommunityPost>.from(_items);
  }

  @override
  Future<CommunityPost> publishPost({
    required String username,
    required String identity,
    required String tag,
    required String title,
    required String location,
    required String summary,
  }) async {
    final created = CommunityPost(
      id: 'created-post',
      username: username,
      identity: identity,
      tag: tag,
      title: title,
      location: location,
      summary: summary,
      createdAtEpochMs: 1774922400000,
      ownerActorId: actorId,
    );
    _items.insert(0, created);
    return created;
  }

  @override
  Future<CommunityPost> respondToPost(String postId) async {
    final index = _items.indexWhere((item) => item.id == postId);
    final updated = _items[index].copyWith(
      responseCount: _items[index].responseCount + 1,
      helperNames: <String>['Test Neighbor', ..._items[index].helperNames],
      respondedByMe: true,
    );
    _items[index] = updated;
    return updated;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'demo_actor_id': _FakeCommunityFeedService.actorId,
      'demo_display_name': 'Test Neighbor',
      'demo_identity_label': 'Building 5',
    });
  });

  testWidgets('renders community feed shell and my summary card', (
    WidgetTester tester,
  ) async {
    final service = _FakeCommunityFeedService(mockPosts);

    await tester.pumpWidget(
      MaterialApp(home: CommunityFeedPage(posts: mockPosts, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('communityServiceShell')), findsOneWidget);
    expect(find.byKey(const Key('communityMySummaryCard')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('communityMyPublishedCount'))).data,
      '0',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('communityMyRespondedCount'))).data,
      '0',
    );
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('summary updates after responding and publishing', (
    WidgetTester tester,
  ) async {
    final service = _FakeCommunityFeedService(mockPosts);

    await tester.pumpWidget(
      MaterialApp(home: CommunityFeedPage(posts: mockPosts, service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('communityFeedLatestTab')));
    await tester.pumpAndSettle();

    final respondButton = find.byKey(
      const Key('communityRespondButton_seed-help-light-bulb'),
    );
    await tester.scrollUntilVisible(
      respondButton,
      300,
      scrollable: find.byType(Scrollable),
    );
    final respondAction = tester.widget<ElevatedButton>(respondButton).onPressed;
    expect(respondAction, isNotNull);
    respondAction!.call();
    await tester.pumpAndSettle();

    expect(
      service._items
          .firstWhere((item) => item.id == 'seed-help-light-bulb')
          .respondedByMe,
      isTrue,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('communityMyRespondedCount')),
      -300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('communityMyRespondedCount'))).data,
      '1',
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('communityPublishNameField')),
      'Zhang Ayi',
    );
    await tester.enterText(
      find.byKey(const Key('communityPublishIdentityField')),
      'Building 5',
    );
    await tester.enterText(
      find.byKey(const Key('communityPublishTitleField')),
      'Clinic companion needed',
    );
    await tester.enterText(
      find.byKey(const Key('communityPublishLocationField')),
      'Chunhe Community',
    );
    await tester.enterText(
      find.byKey(const Key('communityPublishSummaryField')),
      'Need someone to accompany me to the clinic tomorrow afternoon.',
    );
    await tester.tap(find.byKey(const Key('communityPublishSubmitButton')));
    await tester.pumpAndSettle();

    expect(service._items.first.title, 'Clinic companion needed');
    expect(
      tester.widget<Text>(find.byKey(const Key('communityMyPublishedCount'))).data,
      '1',
    );
  });
}
