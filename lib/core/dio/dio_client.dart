import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// Builds the single, app-wide [Dio] instance.
///
/// The base URL already includes the `/api/v1` prefix (see [AppConfig]), so
/// data-layer classes use short relative paths like `/auth/login`.
///
/// The [AuthInterceptor] needs a way to tell the auth layer that the session
/// died (a `401`). To avoid a hard dependency cycle
/// (`dio -> authController -> repository -> api -> dio`), the unauthorized
/// callback is wired lazily: it is only resolved when a 401 actually occurs,
/// which is set from the auth layer via [dioUnauthorizedHandlerProvider].
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      // The backend rejects unknown JSON fields, but that's a request concern;
      // for responses we accept and let models decode what they need.
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      storage: storage,
      onUnauthorized: () async {
        final handler = ref.read(dioUnauthorizedHandlerProvider);
        await handler?.call();
      },
    ),
  );

  return dio;
});

/// Late-bound hook invoked by the [AuthInterceptor] on a `401`.
///
/// The auth controller overrides this (see the auth layer) so it can clear
/// state and trigger a redirect to Login without creating a provider cycle.
final dioUnauthorizedHandlerProvider =
    StateProvider<Future<void> Function()?>((ref) => null);
