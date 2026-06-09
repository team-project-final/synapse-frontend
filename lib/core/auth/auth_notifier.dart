import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/access_token_roles.dart';
import 'package:synapse_frontend/core/auth/auth_repository_exception.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> restoreSession() async {
    state = const AuthState(status: AuthStatus.initializing);
    final tokens = await ref.read(authRepositoryPortProvider).restoreSession();
    if (tokens == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    state = AuthState(
      status: AuthStatus.authenticated,
      accessToken: tokens.accessToken,
      roles: rolesFromAccessToken(tokens.accessToken),
    );
  }

  Future<void> completeOAuthLogin({required String accessToken}) async {
    state = const AuthState(status: AuthStatus.loading);
    final tokens = await ref
        .read(authRepositoryPortProvider)
        .completeOAuthLogin(accessToken: accessToken);
    state = AuthState(
      status: AuthStatus.authenticated,
      accessToken: tokens.accessToken,
      roles: rolesFromAccessToken(tokens.accessToken),
    );
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final tokens = await ref
          .read(authRepositoryPortProvider)
          .login(email: email, password: password);
      state = AuthState(
        status: AuthStatus.authenticated,
        accessToken: tokens.accessToken,
        roles: rolesFromAccessToken(tokens.accessToken),
      );
    } on AuthRepositoryException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: error.detail,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Login failed.',
      );
    }
  }

  void loginWithOAuth(String provider) {
    ref.read(authRepositoryPortProvider).loginWithOAuth(provider);
  }

  void bypassLoginForDevelopment() {
    // 개발용 바이패스는 진짜 JWT가 아니라 roles를 디코드할 수 없으므로,
    // 개발 편의를 위해 ROLE_ADMIN을 부여해 admin 화면까지 확인 가능하게 한다.
    // (실제 인증 활성화 시에는 토큰의 진짜 roles가 사용된다.)
    state = const AuthState(
      status: AuthStatus.authenticated,
      accessToken: 'dev-bypass-token',
      roles: ['ROLE_ADMIN'],
    );
  }

  Future<void> signup(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await ref
          .read(authRepositoryPortProvider)
          .signup(email: email, password: password);
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        successMessage: 'Signup completed. Please log in.',
      );
    } on AuthRepositoryException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: error.detail,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Signup failed.',
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryPortProvider).logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
