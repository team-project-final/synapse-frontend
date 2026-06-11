import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/access_token_roles.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';

String _jwt(Map<String, dynamic> payload) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${seg({'alg': 'RS256'})}.${seg(payload)}.signature';
}

void main() {
  group('rolesFromAccessToken', () {
    test('roles 클레임을 추출한다', () {
      expect(
        rolesFromAccessToken(
          _jwt({
            'roles': ['ROLE_ADMIN', 'ROLE_USER'],
          }),
        ),
        ['ROLE_ADMIN', 'ROLE_USER'],
      );
    });

    test('roles 클레임이 없으면 빈 목록', () {
      expect(rolesFromAccessToken(_jwt({'sub': 'u'})), isEmpty);
    });

    test('JWT 형식이 아니면(바이패스 토큰 등) 빈 목록', () {
      expect(rolesFromAccessToken('not-a-jwt-token'), isEmpty);
    });

    test('null·빈 문자열이면 빈 목록', () {
      expect(rolesFromAccessToken(null), isEmpty);
      expect(rolesFromAccessToken(''), isEmpty);
    });

    test('payload가 깨졌어도 예외 없이 빈 목록', () {
      expect(rolesFromAccessToken('a.b.c'), isEmpty);
    });
  });

  group('AuthState.isAdmin', () {
    test('ROLE_ADMIN 포함 시 true', () {
      expect(const AuthState(roles: ['ROLE_ADMIN']).isAdmin, isTrue);
    });

    test('미포함 시 false', () {
      expect(const AuthState(roles: ['ROLE_USER']).isAdmin, isFalse);
      expect(const AuthState().isAdmin, isFalse);
    });
  });

  group('AuthNotifier roles 배선', () {
    ProviderContainer makeContainer(String token) {
      final c = ProviderContainer(
        overrides: [
          authRepositoryPortProvider.overrideWithValue(_FakeAuthPort(token)),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('login은 admin 토큰이면 isAdmin=true', () async {
      final c = makeContainer(
        _jwt({
          'roles': ['ROLE_ADMIN'],
        }),
      );
      await c.read(authNotifierProvider.notifier).login('e', 'p');
      expect(c.read(authNotifierProvider).isAdmin, isTrue);
    });

    test('login은 일반 사용자 토큰이면 isAdmin=false', () async {
      final c = makeContainer(
        _jwt({
          'roles': ['ROLE_USER'],
        }),
      );
      await c.read(authNotifierProvider.notifier).login('e', 'p');
      expect(c.read(authNotifierProvider).isAdmin, isFalse);
    });
  });
}

class _FakeAuthPort implements AuthRepositoryPort {
  _FakeAuthPort(this._token);

  final String _token;

  @override
  Future<AuthTokens?> restoreSession() async => AuthTokens(accessToken: _token);

  @override
  Future<AuthTokens> completeOAuthLogin({required String accessToken}) async =>
      AuthTokens(accessToken: _token);

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async => AuthTokens(accessToken: _token);

  @override
  Future<void> signup({
    required String email,
    required String password,
  }) async {}

  @override
  void loginWithOAuth(String provider) {}

  @override
  Future<void> logout() async {}
}
