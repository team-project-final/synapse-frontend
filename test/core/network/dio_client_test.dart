import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

void main() {
  test('dioProvider enables credentialed requests for cookie refresh', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);

    expect(dio.options.extra['withCredentials'], isTrue);
  });

  test('aiDioProvider does not attach mock user header outside demo mode', () {
    final container = ProviderContainer(
      overrides: [environmentProvider.overrideWithValue(AppEnvironment.prod)],
    );
    addTearDown(container.dispose);

    final dio = container.read(aiDioProvider);

    expect(dio.options.headers.containsKey('X-User-Id'), isFalse);
  });

  test('aiDioProvider attaches mock user header only in demo mode', () {
    final container = ProviderContainer(
      overrides: [environmentProvider.overrideWithValue(AppEnvironment.demo)],
    );
    addTearDown(container.dispose);

    final dio = container.read(aiDioProvider);

    expect(dio.options.headers['X-User-Id'], 'mock_user_123');
  });
}
