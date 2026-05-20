import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is unauthenticated', () {
    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.accessToken, isNull);
  });

  test('logout resets state to unauthenticated', () {
    container.read(authNotifierProvider.notifier).logout();
    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.unauthenticated);
  });
}
