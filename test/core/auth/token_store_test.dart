import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';

void main() {
  test('in-memory store stores and reads auth access token', () async {
    final store = InMemoryTokenStore();

    await store.save(const AuthTokens(accessToken: 'access'));

    final tokens = await store.read();
    expect(tokens?.accessToken, 'access');
  });

  test('in-memory store clear removes stored tokens', () async {
    final store = InMemoryTokenStore();
    await store.save(const AuthTokens(accessToken: 'access'));

    await store.clear();

    expect(await store.read(), isNull);
  });

  test('secure store stores and reads access token', () async {
    final secureStorage = _FakeSecureTokenStorage();
    final legacyStorage = _FakeLegacyTokenStorage();
    final store = SecureTokenStore(
      secureStorage: secureStorage,
      legacyStorage: legacyStorage,
    );

    await store.save(const AuthTokens(accessToken: 'access'));

    final tokens = await store.read();
    expect(tokens?.accessToken, 'access');
    expect(secureStorage.values['access_token'], 'access');
    expect(legacyStorage.clearCount, 1);
  });

  test('secure store clear removes secure and legacy tokens', () async {
    final secureStorage = _FakeSecureTokenStorage();
    final legacyStorage = _FakeLegacyTokenStorage(accessToken: 'legacy');
    final store = SecureTokenStore(
      secureStorage: secureStorage,
      legacyStorage: legacyStorage,
    );

    await store.save(const AuthTokens(accessToken: 'access'));
    await store.clear();

    expect(await store.read(), isNull);
    expect(secureStorage.values.containsKey('access_token'), isFalse);
    expect(legacyStorage.accessToken, isNull);
  });

  test(
    'migrateLegacyStorage moves legacy access token to secure storage',
    () async {
      final secureStorage = _FakeSecureTokenStorage();
      final legacyStorage = _FakeLegacyTokenStorage(
        accessToken: 'legacy-access',
      );
      final store = SecureTokenStore(
        secureStorage: secureStorage,
        legacyStorage: legacyStorage,
      );

      await store.migrateLegacyStorage();

      final tokens = await store.read();
      expect(tokens?.accessToken, 'legacy-access');
      expect(legacyStorage.accessToken, isNull);
      expect(legacyStorage.clearCount, 1);
    },
  );

  test('migrateLegacyStorage keeps existing secure access token', () async {
    final secureStorage = _FakeSecureTokenStorage(
      values: {'access_token': 'secure-access'},
    );
    final legacyStorage = _FakeLegacyTokenStorage(accessToken: 'legacy-access');
    final store = SecureTokenStore(
      secureStorage: secureStorage,
      legacyStorage: legacyStorage,
    );

    await store.migrateLegacyStorage();

    final tokens = await store.read();
    expect(tokens?.accessToken, 'secure-access');
    expect(legacyStorage.accessToken, isNull);
  });
}

class _FakeSecureTokenStorage implements SecureTokenStorage {
  _FakeSecureTokenStorage({Map<String, String>? values})
    : values = values ?? <String, String>{};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

class _FakeLegacyTokenStorage implements LegacyTokenStorage {
  _FakeLegacyTokenStorage({this.accessToken});

  String? accessToken;
  int clearCount = 0;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<void> clear() async {
    clearCount += 1;
    accessToken = null;
  }
}
