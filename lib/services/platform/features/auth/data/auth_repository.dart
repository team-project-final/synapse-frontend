import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/auth_repository_exception.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/auth_models.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/oauth_redirect.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    tokenStore: ref.watch(tokenStoreProvider),
    oauthRedirectService: ref.watch(oauthRedirectServiceProvider),
  );
});

class AuthRepository implements AuthRepositoryPort {
  const AuthRepository({
    required this.dio,
    required this.tokenStore,
    required this.oauthRedirectService,
  });

  final Dio dio;
  final TokenStore tokenStore;
  final OAuthRedirectService oauthRedirectService;

  @override
  Future<AuthTokens?> restoreSession() async {
    await tokenStore.migrateLegacyStorage();
    return tokenStore.read();
  }

  @override
  Future<AuthTokens> completeOAuthLogin({required String accessToken}) async {
    final tokens = AuthTokens(accessToken: accessToken);
    await tokenStore.save(tokens);
    return tokens;
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );
      final accessToken = response.data?['accessToken'];
      if (accessToken is! String || accessToken.isEmpty) {
        throw const AuthRepositoryException(
          status: 500,
          detail: 'Invalid login response.',
        );
      }

      final tokens = AuthTokens(accessToken: accessToken);
      await tokenStore.save(tokens);
      return tokens;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<void> signup({required String email, required String password}) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/auth/signup',
        data: SignupRequest(email: email, password: password).toJson(),
      );
      SignupResult.fromJson(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  void loginWithOAuth(String provider) {
    oauthRedirectService.redirectToProvider(provider);
  }

  @override
  Future<void> logout() {
    return tokenStore.clear();
  }
}

AuthRepositoryException _mapDioException(DioException error) {
  final response = error.response;
  final data = response?.data;
  final status = response?.statusCode ?? 0;

  final code = data is Map<String, dynamic> && data['code'] is String
      ? data['code'] as String
      : null;
  final detail = data is Map<String, dynamic> && data['detail'] is String
      ? data['detail'] as String
      : null;

  // PLAT-001(잘못된 요청/검증)·PLAT-999(서버 오류)의 detail은 Spring 검증 덤프 같은
  // 내부 메시지라 사용자에게 노출하지 않고 정제된 한국어 메시지로 대체한다.
  // 그 외 비즈니스 코드(PLAT-009-* 등)의 detail은 이미 사용자용 메시지라 보존한다.
  final usesRawDetail = detail != null &&
      detail.isNotEmpty &&
      code != 'PLAT-001' &&
      code != 'PLAT-999';

  return AuthRepositoryException(
    status: status,
    code: code,
    detail: usesRawDetail ? detail : _fallbackAuthMessage(status),
  );
}

String _fallbackAuthMessage(int status) {
  return switch (status) {
    400 => '입력한 정보를 다시 확인해주세요.',
    401 => '이메일 또는 비밀번호가 올바르지 않습니다.',
    409 => '이미 가입된 이메일입니다.',
    423 => '계정이 잠겼습니다. 잠시 후 다시 시도해주세요.',
    _ => '인증 요청에 실패했습니다.',
  };
}
