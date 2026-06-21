import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';
import 'package:synapse_frontend/core/network/auth_dio_interceptor.dart';

final environmentProvider = Provider<AppEnvironment>((ref) {
  const value = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  return parseAppEnvironment(value);
});

// learning-ai 직접 접속용 (Gateway 우회, 로컬 개발)
final aiDioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(environmentProvider);
  final demoUserId = environment.demoUserId;
  return Dio(
    BaseOptions(
      baseUrl: environment.aiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: demoUserId == null ? null : {'X-User-Id': demoUserId},
    ),
  );
});

final dioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(environmentProvider);
  // 빌드 시 --dart-define=API_BASE_URL=<값> 제공 시 override 적용.
  // 값이 빈 문자열이면 동일 오리진 상대경로(gateway 단일 진입점 서빙).
  const hasOverride = bool.hasEnvironment('API_BASE_URL');
  const override = String.fromEnvironment('API_BASE_URL');
  final baseUrl = resolveApiBaseUrl(
    environment,
    apiBaseOverride: hasOverride ? override : null,
  );
  final baseOptions = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    extra: {'withCredentials': true},
  );
  final dio = Dio(baseOptions);
  final refreshDio = Dio(baseOptions);
  dio.interceptors.add(
    AuthDioInterceptor(
      tokenStore: ref.watch(tokenStoreProvider),
      refreshDio: refreshDio,
    ),
  );
  return dio;
});
