import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

void main() {
  test('dioProvider enables credentialed requests for cookie refresh', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);

    expect(dio.options.extra['withCredentials'], isTrue);
  });
}
