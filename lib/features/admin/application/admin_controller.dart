import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_admin_repository.dart';

final fakeAdminRepositoryProvider = Provider((ref) => FakeAdminRepository());

final adminControllerProvider = FutureProvider<AdminSnapshot>(
    (ref) => ref.read(fakeAdminRepositoryProvider).load());
