import '../../../shared/api/api_client.dart';
import '../domain/app_user.dart';
import '../domain/auth_session.dart';

class AuthRepository {
  const AuthRepository(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    return AuthSession.fromJson(json as Map<String, dynamic>);
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final json = await _client.post('/auth/register', body: {
      'email': email,
      'password': password,
      'full_name': fullName,
      'timezone': '',
    });
    return AuthSession.fromJson(json as Map<String, dynamic>);
  }

  Future<AppUser> me() async {
    final json = await _client.get('/auth/me');
    return AppUser.fromProfileJson(json as Map<String, dynamic>);
  }
}
