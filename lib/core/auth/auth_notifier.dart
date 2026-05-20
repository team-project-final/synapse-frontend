import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO: 팀원 구현 — platform-svc 연동
    // 성공 시: state = state.copyWith(status: AuthStatus.authenticated, accessToken: token);
    // 실패 시: state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> loginWithOAuth(String provider) async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO: 팀원 구현 — OAuth PKCE 플로우
  }

  Future<void> signup(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO: 팀원 구현 — platform-svc 연동
  }

  void logout() {
    // TODO: 팀원 구현 — SecureStorage 토큰 삭제
    state = const AuthState();
  }
}
