import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static late SharedPreferences _prefs;

  // Default fallback URLs
  static const String _defaultServerUrl = 'https://api.aicos.gridsphere.in';
  static const String _defaultAiUrl = 'https://rag.aicos.gridsphere.in';

  static const String _keyServerUrl = 'custom_server_url';
  static const String _keyAiUrl = 'custom_ai_url';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String get serverUrl {
    return _prefs.getString(_keyServerUrl) ?? _defaultServerUrl;
  }

  static Future<void> setServerUrl(String url) async {
    if (url.trim().isEmpty) {
      await _prefs.remove(_keyServerUrl);
    } else {
      await _prefs.setString(_keyServerUrl, url.trim());
    }
  }

  static String get aiUrl {
    return _prefs.getString(_keyAiUrl) ?? _defaultAiUrl;
  }

  static Future<void> setAiUrl(String url) async {
    if (url.trim().isEmpty) {
      await _prefs.remove(_keyAiUrl);
    } else {
      await _prefs.setString(_keyAiUrl, url.trim());
    }
  }
}
