enum AuthStatus { initializing, unauthenticated, loading, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initializing,
    this.accessToken,
    this.roles = const [],
    this.errorMessage,
    this.successMessage,
  });

  final AuthStatus status;
  final String? accessToken;
  final List<String> roles;
  final String? errorMessage;
  final String? successMessage;

  bool get isAdmin => roles.contains('ROLE_ADMIN');

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    List<String>? roles,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      roles: roles ?? this.roles,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
