import 'package:shared_preferences/shared_preferences.dart';

class SettingsData {
  const SettingsData({
    required this.model,
  });

  final String model;
}

class SettingsStore {
  static const String apiKeyPreferenceKey = 'openrouter_api_key';
  static const String modelPreferenceKey = 'openrouter_model';
  static const String defaultModel = 'openai/gpt-4o-mini';

  Future<SettingsData> load() async {
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
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(apiKeyPreferenceKey);
    await preferences.setString(modelPreferenceKey, model.trim());
  }
}
