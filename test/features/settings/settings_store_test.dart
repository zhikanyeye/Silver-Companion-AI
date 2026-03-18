import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinling_zhiban_demo/services/settings_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

test('keeps fallback flag false when no saved or env api key exists', () async {
  final store = SettingsStore();

  final settings = await store.load();

  expect(settings.model, SettingsStore.defaultModel);
});

 test('load ignores previously saved api key and returns only model state', () async {
  SharedPreferences.setMockInitialValues({
    SettingsStore.apiKeyPreferenceKey: 'saved-key',
    SettingsStore.modelPreferenceKey: 'saved-model',
  });

  final store = SettingsStore();

  final settings = await store.load();

  expect(settings.model, 'saved-model');
 });

 test('save persists only trimmed model value', () async {
  final store = SettingsStore();

  await store.save(model: '  saved-model  ');
  final settings = await store.load();
  final preferences = await SharedPreferences.getInstance();

  expect(settings.model, 'saved-model');
  expect(preferences.getString(SettingsStore.apiKeyPreferenceKey), isNull);
  expect(
    preferences.getString(SettingsStore.modelPreferenceKey),
    'saved-model',
  );
 });
}
