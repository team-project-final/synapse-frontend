import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return const SecureTokenStore();
});

class AuthTokens {
  const AuthTokens({required this.accessToken});

  final String accessToken;
}

abstract interface class TokenStore {
  Future<void> migrateLegacyStorage();

  Future<void> save(AuthTokens tokens);

  Future<AuthTokens?> read();

  Future<void> clear();
}

class InMemoryTokenStore implements TokenStore {
  AuthTokens? _tokens;

  @override
  Future<void> migrateLegacyStorage() async {}

  @override
  Future<void> save(AuthTokens tokens) async {
    _tokens = tokens;
  }

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> clear() async {
    _tokens = null;
  }
}

abstract interface class SecureTokenStorage {
  Future<String?> read(String key);

  Future<void> write({required String key, required String value});

  Future<void> delete(String key);
}

class FlutterSecureTokenStorage implements SecureTokenStorage {
  const FlutterSecureTokenStorage([
    this._storage = const FlutterSecureStorage(
      webOptions: WebOptions(useSessionStorage: true),
    ),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }
}

abstract interface class LegacyTokenStorage {
  Future<String?> readAccessToken();

  Future<void> clear();
}

class HiveLegacyTokenStorage implements LegacyTokenStorage {
  const HiveLegacyTokenStorage();

  static const _boxName = 'synapse_auth_tokens';
  static const _accessTokenKey = 'access_token';
  static const _legacyRefreshTokenKey = 'refresh_token';

  Future<Box<String>> _openBox() async {
    await Hive.initFlutter();
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  @override
  Future<String?> readAccessToken() async {
    final box = await _openBox();
    return box.get(_accessTokenKey);
  }

  @override
  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_accessTokenKey);
    await box.delete(_legacyRefreshTokenKey);
  }
}

class SecureTokenStore implements TokenStore {
  const SecureTokenStore({
    this.secureStorage = const FlutterSecureTokenStorage(),
    this.legacyStorage = const HiveLegacyTokenStorage(),
  });

  static const _accessTokenKey = 'access_token';

  final SecureTokenStorage secureStorage;
  final LegacyTokenStorage legacyStorage;

  Future<void> _clearLegacyStorage() async {
    await legacyStorage.clear();
  }

  @override
  Future<void> migrateLegacyStorage() async {
    final currentAccessToken = await secureStorage.read(_accessTokenKey);
    final legacyAccessToken = await legacyStorage.readAccessToken();

    if (currentAccessToken == null && legacyAccessToken != null) {
      await secureStorage.write(key: _accessTokenKey, value: legacyAccessToken);
    }

    await _clearLegacyStorage();
  }

  @override
  Future<void> save(AuthTokens tokens) async {
    await secureStorage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _clearLegacyStorage();
  }

  @override
  Future<AuthTokens?> read() async {
    final accessToken = await secureStorage.read(_accessTokenKey);

    if (accessToken == null) {
      return null;
    }

    return AuthTokens(accessToken: accessToken);
  }

  @override
  Future<void> clear() async {
    await secureStorage.delete(_accessTokenKey);
    await _clearLegacyStorage();
  }
}
