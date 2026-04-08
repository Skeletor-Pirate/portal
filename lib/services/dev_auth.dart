// ─────────────────────────────────────────────────────────────────────────────
// DEV AUTH — bypass backend login for UI development / testing
// Remove this file (and all references to DevAuth) before production release.
// ─────────────────────────────────────────────────────────────────────────────

import 'api_service.dart';
import '../models/role_config.dart';

/// Whether dev-mode is active for this session.
/// Screens can check this to skip real API calls and use dummy data instead.
class DevAuth {
  DevAuth._();

  static bool _active = false;

  /// True when the user entered via Dev Login (no real tokens).
  static bool get isActive => _active;

  /// Called when the dev-login button is tapped.
  /// Injects a fake token so TokenStore.hasTokens is true (prevents
  /// accidental 401 redirects), then sets the flag.
  static void activate() {
    _active = true;
    TokenStore.save(access: 'DEV_MOCK_TOKEN', refresh: 'DEV_MOCK_REFRESH');
  }

  /// Maps the UserRole enum to a human-readable dummy name shown in the UI.
  static String dummyName(UserRole role) {
    switch (role) {
      case UserRole.global:      return 'Jordan Wells';
      case UserRole.admin:       return 'Priya Sharma';
      case UserRole.teacher:     return 'Mr. Hoang';
      case UserRole.student:     return 'Alex Rivers';
      case UserRole.parent:      return 'Raj Mehta';
      case UserRole.accountant:  return 'Sarah Chen';
    }
  }

  /// Reset on logout / switch role.
  static void deactivate() {
    _active = false;
    TokenStore.clear();
  }
}
