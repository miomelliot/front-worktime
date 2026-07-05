import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraction over persistent token storage.
///
/// The backend only ever returns an `access_token` plus its `expires_at`
/// (there is no refresh token and no logout endpoint), so this interface is
/// deliberately minimal: read/write/clear the token and its expiry.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<DateTime?> readExpiresAt();

  /// Persist the token and (optionally) its expiry timestamp.
  Future<void> saveToken({required String accessToken, DateTime? expiresAt});

  /// Remove all stored auth material (used by local logout / 401 handling).
  Future<void> clear();
}

/// [TokenStorage] backed by [FlutterSecureStorage].
///
/// Platform behaviour:
/// - Mobile (iOS Keychain / Android EncryptedSharedPreferences) and desktop:
///   values are stored in the OS-provided secure store.
/// - Web: `flutter_secure_storage` uses a WebCrypto-encrypted entry in
///   `localStorage`. SECURITY LIMITATION: browser storage is still readable by
///   any script running on the origin and is vulnerable to XSS. There is no
///   truly secure client-side secret store on the web, and because the backend
///   exposes no refresh-token flow, the access token necessarily lives in
///   browser storage for the session. Keep token lifetimes short server-side.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kExpiresAt = 'expires_at';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);

  @override
  Future<DateTime?> readExpiresAt() async {
    final raw = await _storage.read(key: _kExpiresAt);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> saveToken({
    required String accessToken,
    DateTime? expiresAt,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    if (expiresAt != null) {
      await _storage.write(
        key: _kExpiresAt,
        value: expiresAt.toUtc().toIso8601String(),
      );
    } else {
      await _storage.delete(key: _kExpiresAt);
    }
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kExpiresAt);
  }
}

/// Provides the app-wide [TokenStorage].
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    webOptions: WebOptions(),
  );
  return SecureTokenStorage(storage);
});
