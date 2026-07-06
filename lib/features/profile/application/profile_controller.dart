import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/api/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/app_user.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider =
    Provider((ref) => ProfileRepository(ref.watch(apiClientProvider)));

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, AppUser>(ProfileController.new);

class ProfileController extends AsyncNotifier<AppUser> {
  @override
  Future<AppUser> build() {
    // Watched so switching users on the same device refetches instead of
    // leaving the previous user's profile cached; guards against firing an
    // unauthenticated `/users/me` request (which would 401 and immediately
    // re-trigger `logout()`) during the brief moment after logging out.
    if (ref.watch(authControllerProvider) == null) {
      throw StateError('Не авторизован');
    }
    return ref.read(profileRepositoryProvider).me();
  }

  Future<void> updateProfile({
    required String fullName,
    required String position,
    required String avatarUrl,
    required String timezone,
  }) async {
    final updated = await ref.read(profileRepositoryProvider).update(
          fullName: fullName,
          position: position,
          avatarUrl: avatarUrl,
          timezone: timezone,
        );
    state = AsyncData(updated);
    // Keep the sidebar/header name & role badge in sync with the edit.
    ref.read(authControllerProvider.notifier).setUser(updated);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return ref.read(profileRepositoryProvider).changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
  }
}
