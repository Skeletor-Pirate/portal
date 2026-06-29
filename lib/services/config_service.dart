import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConfigService {
  static late SharedPreferences _prefs;

  // Web uses the local dev backend. Mobile and desktop use the hosted backend by
  // default, but a custom URL can be stored for local/testing environments.
  static const String _defaultServerUrl = 'https://api.aicos.gridsphere.in';
  static const String _defaultAiUrl = 'https://rag.aicos.gridsphere.in';

  static const String _keyServerUrl = 'custom_server_url';
  static const String _keyAiUrl = 'custom_ai_url';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String get serverUrl {
    final custom = _prefs.getString(_keyServerUrl);
    if (custom != null && custom.trim().isNotEmpty) return custom.trim();
    return kIsWeb ? 'http://localhost:8081' : _defaultServerUrl;
  }

  static Future<void> setServerUrl(String url) async {
    if (url.trim().isEmpty) {
      await _prefs.remove(_keyServerUrl);
    } else {
      await _prefs.setString(_keyServerUrl, url.trim());
    }
  }

  static String get aiUrl {
    final custom = _prefs.getString(_keyAiUrl);
    if (custom != null && custom.trim().isNotEmpty) return custom.trim();
    return kIsWeb ? 'http://localhost:8081/ai' : _defaultAiUrl;
  }

  static Future<void> setAiUrl(String url) async {
    if (url.trim().isEmpty) {
      await _prefs.remove(_keyAiUrl);
    } else {
      await _prefs.setString(_keyAiUrl, url.trim());
    }
  }
}
