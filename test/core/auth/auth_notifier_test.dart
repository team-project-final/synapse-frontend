import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';

void main() {
  late ProviderContainer container;
  late InMemoryTokenStore tokenStore;

  setUp(() {
    tokenStore = InMemoryTokenStore();
    container = ProviderContainer(
      overrides: [tokenStoreProvider.overrideWithValue(tokenStore)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is initializing', () {
    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.initializing);
    expect(state.accessToken, isNull);
  });

  test('restoreSession without tokens resolves to unauthenticated', () async {
    await container.read(authNotifierProvider.notifier).restoreSession();

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.accessToken, isNull);
    expect(state.refreshToken, isNull);
  });

  test('completeOAuthLogin stores tokens and authenticates', () async {
    await container
        .read(authNotifierProvider.notifier)
        .completeOAuthLogin(accessToken: 'access', refreshToken: 'refresh');

    final state = container.read(authNotifierProvider);
    final tokens = await tokenStore.read();

    expect(state.status, AuthStatus.authenticated);
    expect(state.accessToken, 'access');
    expect(state.refreshToken, 'refresh');
    expect(tokens?.accessToken, 'access');
    expect(tokens?.refreshToken, 'refresh');
  });

  test('restoreSession authenticates when stored tokens exist', () async {
    await tokenStore.save(
      const AuthTokens(
        accessToken: 'stored-access',
        refreshToken: 'stored-refresh',
      ),
    );

    await container.read(authNotifierProvider.notifier).restoreSession();

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.accessToken, 'stored-access');
    expect(state.refreshToken, 'stored-refresh');
  });

  test('logout clears tokens and resets state to unauthenticated', () async {
    await container
        .read(authNotifierProvider.notifier)
        .completeOAuthLogin(accessToken: 'access', refreshToken: 'refresh');

    await container.read(authNotifierProvider.notifier).logout();

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(await tokenStore.read(), isNull);
  });
}
