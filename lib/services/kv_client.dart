import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class KvClient {
  const KvClient({this.baseUrl = ''});

  /// The base URL for the API. When running on Web (Cloudflare Pages), 
  /// this can be empty to use relative paths.
  final String baseUrl;

  String _buildUrl(String key) {
    String basePath = baseUrl;
    if (basePath.isEmpty) {
      basePath = const String.fromEnvironment(
        'AI_KV_URL',
        defaultValue: '/api/kv',
      );
    }
    
    // Ensure basePath doesn't end with a trailing slash so we don't get //key
    final normalizedPath = basePath.endsWith('/') 
        ? basePath.substring(0, basePath.length - 1) 
        : basePath;
        
    final configuredUri = Uri.parse('$normalizedPath/$key');
    if (configuredUri.hasScheme) {
      return configuredUri.toString();
    }
    return Uri.base.resolveUri(configuredUri).toString();
  }

  /// Retrieves data from KV by [key].
  Future<Map<String, dynamic>?> get(String key) async {
    try {
      final url = Uri.parse(_buildUrl(key));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null; // Key doesn't exist
      } else {
        debugPrint('KV Get Error (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('KV Get Exception: $e');
      return null;
    }
  }

  /// Puts [data] into KV under [key]. Overwrites existing data.
  Future<bool> put(String key, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(_buildUrl(key));
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('KV Put Error (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('KV Put Exception: $e');
      return false;
    }
  }

  /// Deletes [key] from KV.
  Future<bool> delete(String key) async {
    try {
      final url = Uri.parse(_buildUrl(key));
      final response = await http.delete(url);
      
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('KV Delete Error (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('KV Delete Exception: $e');
      return false;
    }
  }
}
