import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionStore {
  static const String isLoggedInPreferenceKey = 'auth_is_logged_in';

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(isLoggedInPreferenceKey) ?? false;
  }

  Future<void> markLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(isLoggedInPreferenceKey, true);
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(isLoggedInPreferenceKey, false);
  }
}
