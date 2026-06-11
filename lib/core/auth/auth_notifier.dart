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
        errorMessage: '로그인에 실패했습니다.',
      );
    }
  }

  void loginWithOAuth(String provider) {
    ref.read(authRepositoryPortProvider).loginWithOAuth(provider);
  }

  /// 개발용 로그인 바이패스. 실제 인증 없이 인증 상태로 진입한다.
  /// 진짜 JWT가 아니라 토큰의 roles를 디코드할 수 없으므로, 개발 편의를 위해
  /// ROLE_ADMIN을 부여해 admin 화면까지 둘러볼 수 있게 한다.
  /// ⚠ 토큰이 가짜라 실제 보호 API 호출은 401이 난다(화면 탐색용).
  /// 실 로그인 복구는 login_screen._submit의 안내 참고.
  void bypassLoginForDevelopment() {
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
        errorMessage: '회원가입에 실패했습니다.',
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryPortProvider).logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
