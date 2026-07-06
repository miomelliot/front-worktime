import '../../../shared/api/api_client.dart';
import '../../auth/domain/app_user.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final ApiClient _client;

  Future<AppUser> me() async {
    final json = await _client.get('/users/me');
    return AppUser.fromProfileJson(json as Map<String, dynamic>);
  }

  Future<AppUser> update({
    required String fullName,
    required String position,
    required String avatarUrl,
    required String timezone,
  }) async {
    final json = await _client.patch('/users/me', body: {
      'full_name': fullName,
      'position': position,
      'avatar_url': avatarUrl,
      'timezone': timezone,
    });
    return AppUser.fromProfileJson(json as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _client.post('/users/me/password', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }
}
