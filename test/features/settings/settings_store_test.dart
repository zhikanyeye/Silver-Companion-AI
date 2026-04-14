import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinling/services/demo_identity_store.dart';
import 'package:yinling/services/kv_client.dart';
import 'package:yinling/services/settings_store.dart';

class _FakeKvClient extends KvClient {
  _FakeKvClient({this.data});

  Map<String, dynamic>? data;
  Map<String, dynamic>? lastPutData;
  String? lastPutKey;

  @override
  Future<Map<String, dynamic>?> get(String key) async => data;

  @override
  Future<bool> put(String key, Map<String, dynamic> value) async {
    lastPutKey = key;
    lastPutData = value;
    data = value;
    return true;
  }
}

class _FakeIdentityStore extends DemoIdentityStore {
  @override
  Future<DemoIdentity> loadOrCreate() async {
    return const DemoIdentity(
      actorId: 'guest-test',
      displayName: 'Test User',
      identityLabel: 'Resident',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('load falls back to default model when no local or remote data exists', () async {
    final store = SettingsStore(
      kvClient: _FakeKvClient(),
      identityStore: _FakeIdentityStore(),
    );

    final settings = await store.load();

    expect(settings.model, SettingsStore.defaultModel);
  });

  test('load prefers remote kv model when present', () async {
    final store = SettingsStore(
      kvClient: _FakeKvClient(data: <String, dynamic>{'model': 'remote-model'}),
      identityStore: _FakeIdentityStore(),
    );

    final settings = await store.load();

    expect(settings.model, 'remote-model');
  });

  test('save persists trimmed model locally and syncs it to kv', () async {
    final kvClient = _FakeKvClient();
    final store = SettingsStore(
      kvClient: kvClient,
      identityStore: _FakeIdentityStore(),
    );

    await store.save(model: '  saved-model  ');
    final settings = await store.load();
    final preferences = await SharedPreferences.getInstance();

    expect(settings.model, 'saved-model');
    expect(
      preferences.getString(SettingsStore.modelPreferenceKey),
      'saved-model',
    );
    expect(kvClient.lastPutKey, 'user_settings_guest-test');
    expect(kvClient.lastPutData, <String, dynamic>{'model': 'saved-model'});
  });
}
