import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_profile.dart';

part 'auth_state.freezed.dart';

/// Auth session state consumed by the router and UI.
///
/// - [AuthState.unknown] is the initial state while the app tries to restore a
///   session from stored token (`GET /users/me`). The router shows a splash.
/// - [AuthState.authenticated] carries the current [UserProfile].
/// - [AuthState.unauthenticated] means no valid session; the router redirects
///   to Login. An optional [message] surfaces e.g. "session expired".
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unknown() = AuthUnknown;

  const factory AuthState.authenticated(UserProfile user) = AuthAuthenticated;

  const factory AuthState.unauthenticated({String? message}) =
      AuthUnauthenticated;
}

extension AuthStateX on AuthState {
  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isUnknown => this is AuthUnknown;

  UserProfile? get userOrNull =>
      this is AuthAuthenticated ? (this as AuthAuthenticated).user : null;
}
