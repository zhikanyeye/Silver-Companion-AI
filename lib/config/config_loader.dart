import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yinling_zhiban_demo/config/app_config.dart';

class ConfigLoader {
  Future<AppConfig?> load() async {
    try {
      final res = await http.get(Uri.parse('/config.json'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        return AppConfig.fromJson(data);
      }
    } catch (_) {
      // Ignore and return null to fallback to defaults
    }
    return null;
  }
}
