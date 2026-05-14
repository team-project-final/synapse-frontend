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
  return Dio(
    BaseOptions(
      baseUrl: environment.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
});
