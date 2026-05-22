import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return const HiveTokenStore();
});

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

abstract interface class TokenStore {
  Future<void> save(AuthTokens tokens);

  Future<AuthTokens?> read();

  Future<void> clear();
}

class InMemoryTokenStore implements TokenStore {
  AuthTokens? _tokens;

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

class HiveTokenStore implements TokenStore {
  const HiveTokenStore();

  static const _boxName = 'synapse_auth_tokens';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<Box<String>> _openBox() async {
    await Hive.initFlutter();
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  @override
  Future<void> save(AuthTokens tokens) async {
    final box = await _openBox();
    await box.put(_accessTokenKey, tokens.accessToken);
    await box.put(_refreshTokenKey, tokens.refreshToken);
  }

  @override
  Future<AuthTokens?> read() async {
    final box = await _openBox();
    final accessToken = box.get(_accessTokenKey);
    final refreshToken = box.get(_refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_accessTokenKey);
    await box.delete(_refreshTokenKey);
  }
}
