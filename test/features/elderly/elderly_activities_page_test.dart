import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yinling_zhiban_demo/features/elderly/elderly_activities_page.dart';
import 'package:yinling_zhiban_demo/features/elderly/elderly_activities_service.dart';
import 'package:yinling_zhiban_demo/features/elderly/mock_service_data.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class _FakeElderlyActivitiesService extends ElderlyActivitiesService {
  static const actorId = 'guest-test-activity';

  _FakeElderlyActivitiesService(List<ElderlyActivityItem> items)
    : _items = List<ElderlyActivityItem>.from(items);

  final List<ElderlyActivityItem> _items;

  @override
  Future<List<ElderlyActivityItem>> loadActivities() async {
    return List<ElderlyActivityItem>.from(_items);
  }

  @override
  Future<ElderlyActivityItem> joinActivity(String activityId) async {
    final index = _items.indexWhere((item) => item.id == activityId);
    final updated = _items[index].copyWith(
      joinedCount: _items[index].joinedCount + 1,
      participantNames: <String>['Test Signup', ..._items[index].participantNames],
      joinedByMe: true,
    );
    _items[index] = updated;
    return updated;
  }

  @override
  Future<ElderlyActivityItem> publishActivity({
    required String organizerName,
    required String title,
    required String location,
    required String description,
    required String tag,
    required String time,
    required ElderlyActivityGroup group,
  }) async {
    final item = ElderlyActivityItem(
      id: 'created-activity',
      time: time,
      title: title,
      location: location,
      description: description,
      tag: tag,
      organizerName: organizerName,
      organizerActorId: actorId,
      group: group,
      createdAtEpochMs: 1775266200000,
    );
    _items.insert(0, item);
    return item;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'demo_actor_id': _FakeElderlyActivitiesService.actorId,
      'demo_display_name': 'Test Activity Partner',
      'demo_identity_label': 'Resident',
    });
  });

  testWidgets('activities page shows my summary and supports signup', (
    WidgetTester tester,
  ) async {
    final service = _FakeElderlyActivitiesService(<ElderlyActivityItem>[
      ...todayRecommendedActivities,
      ...weeklyActivities,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: ElderlyActivitiesPage(service: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('activitiesMySummaryCard')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('activitiesMyCreatedCount'))).data,
      '0',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('activitiesMyJoinedCount'))).data,
      '0',
    );

    final joinButton = find.byKey(
      const Key('activityJoinButton_seed-morning-exercise'),
    );
    await tester.scrollUntilVisible(
      joinButton,
      300,
      scrollable: find.byType(Scrollable),
    );
    final joinAction = tester.widget<ElevatedButton>(joinButton).onPressed;
    expect(joinAction, isNotNull);
    joinAction!.call();
    await tester.pumpAndSettle();

    expect(
      service._items
          .firstWhere((item) => item.id == 'seed-morning-exercise')
          .joinedByMe,
      isTrue,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('activitiesMyJoinedCount')),
      -300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('activitiesMyJoinedCount'))).data,
      '1',
    );
  });

  testWidgets('can publish a new activity and update my summary', (
    WidgetTester tester,
  ) async {
    final service = _FakeElderlyActivitiesService(<ElderlyActivityItem>[
      ...todayRecommendedActivities,
      ...weeklyActivities,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.highContrast(),
        home: ElderlyActivitiesPage(service: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('activityPublishOrganizerField')),
      'Station Lead Zhou',
    );
    await tester.enterText(
      find.byKey(const Key('activityPublishTitleField')),
      'Friday tea talk',
    );
    await tester.enterText(
      find.byKey(const Key('activityPublishLocationField')),
      'Community Center',
    );
    await tester.enterText(
      find.byKey(const Key('activityPublishTimeField')),
      'Fri 15:00',
    );
    await tester.enterText(
      find.byKey(const Key('activityPublishDescriptionField')),
      'Neighbors are welcome to talk about recent changes in the community.',
    );
    await tester.tap(find.byKey(const Key('activityPublishSubmitButton')));
    await tester.pumpAndSettle();

    expect(service._items.first.title, 'Friday tea talk');
    expect(
      tester.widget<Text>(find.byKey(const Key('activitiesMyCreatedCount'))).data,
      '1',
    );
  });
}
