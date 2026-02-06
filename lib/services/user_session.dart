import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final ValueNotifier<String?> userNameNotifier = ValueNotifier(null);
  static final ValueNotifier<String?> emailNotifier = ValueNotifier(null);
  static final ValueNotifier<String?> roleNotifier = ValueNotifier(null);
  static final ValueNotifier<String?> tokenNotifier = ValueNotifier(null);

  static String? get userName => userNameNotifier.value;
  static set userName(String? v) {
    userNameNotifier.value = v;
    _saveToPrefs('user_name', v);
  }

  static String? get email => emailNotifier.value;
  static set email(String? v) {
    emailNotifier.value = v;
    _saveToPrefs('user_email', v);
  }

  static String? get role => roleNotifier.value;
  static set role(String? v) {
    roleNotifier.value = v;
    _saveToPrefs('user_role', v);
  }

  // 🔐 JWT TOKEN (OPTIONAL / FUTURE USE)
  static String? get token => tokenNotifier.value;
  static set token(String? v) {
    tokenNotifier.value = v;
    _saveToPrefs('user_token', v);
  }

  // ✅ LOGIN CHECK (SESSION STYLE)
  static bool get isLoggedIn => email != null;

  static void clear() {
    userNameNotifier.value = null;
    emailNotifier.value = null;
    roleNotifier.value = null;
    tokenNotifier.value = null;
    _clearPrefs();
  }

  // Load session from shared preferences
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userNameNotifier.value = prefs.getString('user_name');
    emailNotifier.value = prefs.getString('user_email');
    roleNotifier.value = prefs.getString('user_role');
    tokenNotifier.value = prefs.getString('user_token');
  }

  // Save individual value to shared preferences
  static Future<void> _saveToPrefs(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  // Clear all session data from shared preferences
  static Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_token');
  }
}
