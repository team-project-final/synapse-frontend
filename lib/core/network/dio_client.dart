import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';
import 'package:synapse_frontend/core/network/auth_dio_interceptor.dart';

final environmentProvider = Provider<AppEnvironment>((ref) {
  const value = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  return parseAppEnvironment(value);
});

// learning-svc 직접 접속용 (Gateway 우회, 로컬 개발 — 포트 8084)
final learningDioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(environmentProvider);
  return Dio(BaseOptions(
    baseUrl: environment.learningBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: const {
      'X-User-Id': '00000000-0000-0000-0000-000000000001',
      'X-Tenant-Id': '00000000-0000-0000-0000-000000000001',
    },
  ));
});

// learning-ai 직접 접속용 (Gateway 우회, 로컬 개발)
final aiDioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(environmentProvider);
  return Dio(BaseOptions(
    baseUrl: environment.aiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'X-User-Id': 'mock_user_123'},
  ));
});

final dioProvider = Provider<Dio>((ref) {
  final environment = ref.watch(environmentProvider);
  final baseOptions = BaseOptions(
    baseUrl: environment.baseUrl,
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
