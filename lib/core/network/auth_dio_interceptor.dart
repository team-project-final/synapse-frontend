import 'package:dio/dio.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';

class AuthDioInterceptor extends QueuedInterceptor {
  AuthDioInterceptor({required this.tokenStore, required this.refreshDio});

  static const _retriedKey = 'synapse_auth_retry';

  final TokenStore tokenStore;
  final Dio refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await tokenStore.read();
    if (tokens != null && !_isRefreshRequest(options)) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (statusCode != 401 ||
        alreadyRetried ||
        _isRefreshRequest(err.requestOptions)) {
      handler.next(err);
      return;
    }

    try {
      final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
      );
      final data = refreshResponse.data;
      final accessToken = data?['accessToken'];

      if (accessToken is! String) {
        await tokenStore.clear();
        handler.next(err);
        return;
      }

      final newTokens = AuthTokens(accessToken: accessToken);
      await tokenStore.save(newTokens);

      final requestOptions = err.requestOptions;
      requestOptions.extra[_retriedKey] = true;
      requestOptions.headers['Authorization'] =
          'Bearer ${newTokens.accessToken}';

      final retryResponse = await refreshDio.fetch<dynamic>(requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await tokenStore.clear();
      handler.next(err);
    }
  }

  bool _isRefreshRequest(RequestOptions options) {
    return options.path == '/api/v1/auth/refresh';
  }
}
