import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> restoreSession() async {
    state = const AuthState(status: AuthStatus.initializing);
    final tokens = await ref.read(tokenStoreProvider).read();
    if (tokens == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    state = AuthState(
      status: AuthStatus.authenticated,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<void> completeOAuthLogin({
    required String accessToken,
    required String refreshToken,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    await ref
        .read(tokenStoreProvider)
        .save(AuthTokens(accessToken: accessToken, refreshToken: refreshToken));
    state = AuthState(
      status: AuthStatus.authenticated,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO: 팀원 구현 — platform-svc 연동
    // 성공 시: state = state.copyWith(status: AuthStatus.authenticated, accessToken: token);
    // 실패 시: state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> loginWithOAuth(String provider) async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO: 팀원 구현 — 서버 사이드 OAuth redirect 연동
  }

  Future<void> signup(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO: 팀원 구현 — platform-svc 연동
  }

  Future<void> logout() async {
    // TODO: 팀원 구현 — SecureStorage 토큰 삭제
    await ref.read(tokenStoreProvider).clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
