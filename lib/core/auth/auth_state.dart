enum AuthStatus { initializing, unauthenticated, loading, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initializing,
    this.accessToken,
    this.errorMessage,
    this.successMessage,
  });

  final AuthStatus status;
  final String? accessToken;
  final String? errorMessage;
  final String? successMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
