import 'package:shared_preferences/shared_preferences.dart';
import 'package:yinling/services/demo_identity_store.dart';
import 'package:yinling/services/kv_client.dart';

class SettingsData {
  const SettingsData({required this.model});

  final String model;
}

class SettingsStore {
  SettingsStore({KvClient? kvClient, DemoIdentityStore? identityStore})
    : _kvClient = kvClient ?? const KvClient(),
      _identityStore = identityStore ?? DemoIdentityStore();

  final KvClient _kvClient;
  final DemoIdentityStore _identityStore;

  static const String modelPreferenceKey = 'openrouter_model';
  static const String defaultModel = 'openai/gpt-4o-mini';

  Future<String> _settingsKey() async {
    final identity = await _identityStore.loadOrCreate();
    return 'user_settings_${identity.actorId}';
  }

  Future<SettingsData> load() async {
    final kvData = await _kvClient.get(await _settingsKey());
    if (kvData != null && kvData['model'] is String) {
      return SettingsData(model: kvData['model'] as String);
    }

    final preferences = await SharedPreferences.getInstance();
    final savedModel = preferences.getString(modelPreferenceKey) ?? '';
    final fallbackModel = const String.fromEnvironment(
      'OPENROUTER_MODEL',
      defaultValue: defaultModel,
    );

    return SettingsData(
      model: savedModel.isEmpty ? fallbackModel : savedModel,
    );
  }

  Future<void> save({required String model}) async {
    final cleanModel = model.trim();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(modelPreferenceKey, cleanModel);
    await _kvClient.put(await _settingsKey(), <String, dynamic>{
      'model': cleanModel,
    });
  }
}
