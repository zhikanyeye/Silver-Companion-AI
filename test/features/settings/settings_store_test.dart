import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinling_zhiban_demo/services/settings_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads fallback key and model when preferences are empty', () async {
    final store = SettingsStore();

    final settings = await store.load();

    expect(settings.apiKey, '');
    expect(settings.model, SettingsStore.defaultModel);
    expect(settings.usingFallbackApiKey, isTrue);
  });

  test('save then load returns saved values and disables fallback flag', () async {
    final store = SettingsStore();

    await store.save(apiKey: 'saved-key', model: 'saved-model');
    final settings = await store.load();

    expect(settings.apiKey, 'saved-key');
    expect(settings.model, 'saved-model');
    expect(settings.usingFallbackApiKey, isFalse);
  });
}
