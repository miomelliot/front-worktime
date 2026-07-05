import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';

final fakeAuthRepositoryProvider = Provider((ref) => FakeAuthRepository());

final authControllerProvider =
    NotifierProvider<AuthController, AppUser?>(AuthController.new);

class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  Future<void> loginAs(UserRole role) async {
    state = await ref.read(fakeAuthRepositoryProvider).loginAs(role);
  }

  void logout() => state = null;
}
