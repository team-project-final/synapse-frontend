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

  if (data is Map<String, dynamic>) {
    final code = data['code'];
    final detail = data['detail'];
    return AuthRepositoryException(
      status: status,
      code: code is String ? code : null,
      detail: detail is String && detail.isNotEmpty
          ? detail
          : _fallbackAuthMessage(status),
    );
  }

  return AuthRepositoryException(
    status: status,
    detail: _fallbackAuthMessage(status),
  );
}

String _fallbackAuthMessage(int status) {
  return switch (status) {
    400 => 'Please check the request.',
    401 => 'Email or password is incorrect.',
    409 => 'Email is already registered.',
    423 => 'Account is locked. Please try again later.',
    _ => 'Authentication request failed.',
  };
}
