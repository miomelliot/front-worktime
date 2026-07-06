import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import '../../features/auth/domain/app_user.dart';

/// Persists the current session in the browser's localStorage so it
/// survives a page reload or browser restart — without this, every reload
/// forced a fresh login even with a long-lived token. Web-only by design
/// (this app has no other target); `dart:html` gives synchronous access,
/// which matters here since [AuthController.build] needs the cached user
/// available immediately, with no loading flash before the redirect logic
/// in the router runs.
class TokenStorage {
  const TokenStorage._();

  static const _tokenKey = 'worktime.auth.token';
  static const _userKey = 'worktime.auth.user';

  static void save(String token, AppUser user) {
    html.window.localStorage[_tokenKey] = token;
    html.window.localStorage[_userKey] = jsonEncode(user.toJson());
  }

  static ({String token, AppUser user})? load() {
    final token = html.window.localStorage[_tokenKey];
    final userJson = html.window.localStorage[_userKey];
    if (token == null || userJson == null) return null;
    try {
      final user =
          AppUser.fromProfileJson(jsonDecode(userJson) as Map<String, dynamic>);
      return (token: token, user: user);
    } catch (_) {
      // Corrupt/old-shape cache — treat as no session rather than crash.
      return null;
    }
  }

  static void clear() {
    html.window.localStorage.remove(_tokenKey);
    html.window.localStorage.remove(_userKey);
  }
}
