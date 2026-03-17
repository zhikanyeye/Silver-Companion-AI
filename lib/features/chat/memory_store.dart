import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryStore {
  static const _key = 'yinling_memory';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return <String>[];
    try {
      final List<dynamic> data = jsonDecode(jsonStr);
      return data.map((e) => e.toString()).toList();
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> save(List<String> memory) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(memory);
    await prefs.setString(_key, jsonStr);
  }
}
