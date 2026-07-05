import '../../../shared/mock/mock_users.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';

class FakeAuthRepository {
  Future<AppUser> loginAs(UserRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return mockUsers.firstWhere((user) => user.role == role);
  }
}
