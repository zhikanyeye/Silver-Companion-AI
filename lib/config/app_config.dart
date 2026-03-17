class AppConfig {
  final String modelName;
  final String apiBaseUrl;
  final String apiKey;

  AppConfig({required this.modelName, required this.apiBaseUrl, required this.apiKey});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      modelName: json['model_name'] ?? 'openai/gpt-4o-mini',
      apiBaseUrl: json['api_base_url'] ?? '',
      apiKey: json['api_key'] ?? '',
    );
  }
}
