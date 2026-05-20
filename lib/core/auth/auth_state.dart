enum AuthStatus { unauthenticated, loading, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.accessToken,
    this.refreshToken,
  });

  final AuthStatus status;
  final String? accessToken;
  final String? refreshToken;

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
