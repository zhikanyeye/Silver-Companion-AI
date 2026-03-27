class AppConfig {
  final String modelName;

  AppConfig({required this.modelName});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      modelName: json['model_name'] ?? 'openai/gpt-4o-mini',
    );
  }
}
