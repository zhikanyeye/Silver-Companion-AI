class AppConfig {
  final String modelName;
  final String? ttsApiBaseUrl;

  AppConfig({required this.modelName, this.ttsApiBaseUrl});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      modelName: json['model_name'] ?? 'openai/gpt-4o-mini',
      ttsApiBaseUrl: json['tts_api_base_url'] as String?,
    );
  }
}
