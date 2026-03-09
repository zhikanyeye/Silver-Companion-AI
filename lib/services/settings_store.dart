import 'package:shared_preferences/shared_preferences.dart';

class SettingsData {
  const SettingsData({
    required this.apiKey,
    required this.model,
    required this.usingFallbackApiKey,
  });

  final String apiKey;
  final String model;
  final bool usingFallbackApiKey;
}

class SettingsStore {
  static const String apiKeyPreferenceKey = 'openrouter_api_key';
  static const String modelPreferenceKey = 'openrouter_model';
  static const String defaultModel = 'openai/gpt-4o-mini';

  Future<SettingsData> load() async {
    final preferences = await SharedPreferences.getInstance();

    final savedApiKey = preferences.getString(apiKeyPreferenceKey) ?? '';
    final savedModel = preferences.getString(modelPreferenceKey) ?? '';

    final fallbackApiKey = const String.fromEnvironment(
      'OPENROUTER_API_KEY',
      defaultValue: '',
    );
    final fallbackModel = const String.fromEnvironment(
      'OPENROUTER_MODEL',
      defaultValue: defaultModel,
    );

    final usingFallbackApiKey = savedApiKey.isEmpty && fallbackApiKey.isNotEmpty;

    return SettingsData(
      apiKey: usingFallbackApiKey ? fallbackApiKey : savedApiKey,
      model: savedModel.isEmpty ? fallbackModel : savedModel,
      usingFallbackApiKey: usingFallbackApiKey,
    );
  }

  Future<void> save({required String apiKey, required String model}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(apiKeyPreferenceKey, apiKey.trim());
    await preferences.setString(modelPreferenceKey, model.trim());
  }
}
