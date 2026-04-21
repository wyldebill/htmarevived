import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionManager {
  AuthSessionManager({
    required FirebaseAuth auth,
    required SharedPreferences preferences,
  }) : _auth = auth,
       _preferences = preferences;

  static const sessionDuration = Duration(days: 30);
  static const _lastLoginAtKey = 'auth_last_login_at_ms';

  final FirebaseAuth _auth;
  final SharedPreferences _preferences;

  Future<void> enforceSessionWindow() async {
    final user = _auth.currentUser;
    if (user == null) {
      await _clearLoginTimestamp();
      return;
    }

    final lastLoginAtMs = _preferences.getInt(_lastLoginAtKey);
    if (lastLoginAtMs == null) {
      await signOut();
      return;
    }

    final lastLoginAt = DateTime.fromMillisecondsSinceEpoch(lastLoginAtMs);
    final expiresAt = lastLoginAt.add(sessionDuration);
    if (DateTime.now().isAfter(expiresAt)) {
      await signOut();
    }
  }

  Future<void> markLoginSuccess() {
    return _preferences.setInt(
      _lastLoginAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _clearLoginTimestamp();
  }

  Future<void> _clearLoginTimestamp() {
    return _preferences.remove(_lastLoginAtKey);
  }
}
