import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';

void main() {
  test('stores and reads auth tokens', () async {
    final store = InMemoryTokenStore();

    await store.save(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    );

    final tokens = await store.read();
    expect(tokens?.accessToken, 'access');
    expect(tokens?.refreshToken, 'refresh');
  });

  test('clear removes stored tokens', () async {
    final store = InMemoryTokenStore();
    await store.save(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    );

    await store.clear();

    expect(await store.read(), isNull);
  });
}
