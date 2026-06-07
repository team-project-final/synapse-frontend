import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';

final environmentProvider = Provider<AppEnvironment>((ref) {
  const value = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  return switch (value) {
    'prod' => AppEnvironment.prod,
    'staging' => AppEnvironment.staging,
    _ => AppEnvironment.dev,
  };
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
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
});
