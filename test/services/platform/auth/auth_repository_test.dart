import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_repository_exception.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/auth_repository.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/oauth_redirect.dart';

void main() {
  test('restoreSession migrates storage before reading tokens', () async {
    final tokenStore = _RecordingTokenStore(
      tokens: const AuthTokens(accessToken: 'stored-access'),
    );
    final repository = AuthRepository(
      dio: Dio(BaseOptions(baseUrl: 'http://localhost:8081')),
      tokenStore: tokenStore,
      oauthRedirectService: _oauthRedirectService(),
    );

    final tokens = await repository.restoreSession();

    expect(tokens?.accessToken, 'stored-access');
    expect(tokenStore.calls, ['migrate', 'read']);
  });

  test('completeOAuthLogin stores and returns access token', () async {
    final tokenStore = InMemoryTokenStore();
    final repository = AuthRepository(
      dio: Dio(BaseOptions(baseUrl: 'http://localhost:8081')),
      tokenStore: tokenStore,
      oauthRedirectService: _oauthRedirectService(),
    );

    final tokens = await repository.completeOAuthLogin(accessToken: 'access');

    expect(tokens.accessToken, 'access');
    expect((await tokenStore.read())?.accessToken, 'access');
  });

  test('loginWithOAuth redirects to provider authorization URL', () {
    final redirectedUrls = <String>[];
    final repository = AuthRepository(
      dio: Dio(BaseOptions(baseUrl: 'http://localhost:8081')),
      tokenStore: InMemoryTokenStore(),
      oauthRedirectService: OAuthRedirectService(
        baseUrl: 'http://localhost:8081',
        redirect: redirectedUrls.add,
      ),
    );

    repository.loginWithOAuth('google');

    expect(redirectedUrls, [
      'http://localhost:8081/oauth2/authorization/google',
    ]);
  });

  test('logout clears stored tokens', () async {
    final tokenStore = InMemoryTokenStore();
    await tokenStore.save(const AuthTokens(accessToken: 'access'));
    final repository = AuthRepository(
      dio: Dio(BaseOptions(baseUrl: 'http://localhost:8081')),
      tokenStore: tokenStore,
      oauthRedirectService: _oauthRedirectService(),
    );

    await repository.logout();

    expect(await tokenStore.read(), isNull);
  });

  test(
    'login posts credentials, saves access token, and returns tokens',
    () async {
      final tokenStore = InMemoryTokenStore();
      final adapter = _FakeAdapter((request) {
        expect(request.path, '/api/v1/auth/login');
        expect(request.data, {
          'email': 'user@example.com',
          'password': 'P@ssw0rd!',
        });
        return _json({'accessToken': 'access'}, 200);
      });
      final repository = _repository(tokenStore: tokenStore, adapter: adapter);

      final tokens = await repository.login(
        email: 'user@example.com',
        password: 'P@ssw0rd!',
      );

      expect(tokens.accessToken, 'access');
      expect((await tokenStore.read())?.accessToken, 'access');
    },
  );

  test('login invalid response throws repository exception', () async {
    final repository = _repository(
      adapter: _FakeAdapter((request) => _json({'token': 'missing'}, 200)),
    );

    expect(
      () => repository.login(email: 'user@example.com', password: 'P@ssw0rd!'),
      throwsA(
        isA<AuthRepositoryException>().having(
          (error) => error.status,
          'status',
          500,
        ),
      ),
    );
  });

  test('login preserves invalid credentials error detail', () async {
    final repository = _repository(
      adapter: _FakeAdapter(
        (request) => _json({
          'status': 401,
          'code': 'PLAT-009-002',
          'detail': '이메일 또는 비밀번호가 올바르지 않습니다',
        }, 401),
      ),
    );

    await expectLater(
      repository.login(email: 'user@example.com', password: 'bad-password'),
      throwsA(
        isA<AuthRepositoryException>()
            .having((error) => error.status, 'status', 401)
            .having((error) => error.code, 'code', 'PLAT-009-002')
            .having(
              (error) => error.detail,
              'detail',
              '이메일 또는 비밀번호가 올바르지 않습니다',
            ),
      ),
    );
  });

  test('login preserves social account error code', () async {
    final repository = _repository(
      adapter: _FakeAdapter(
        (request) => _json({
          'status': 401,
          'code': 'PLAT-009-003',
          'detail': '이 이메일은 소셜 로그인으로 가입되었습니다',
        }, 401),
      ),
    );

    await expectLater(
      repository.login(email: 'social@example.com', password: 'P@ssw0rd!'),
      throwsA(
        isA<AuthRepositoryException>()
            .having((error) => error.status, 'status', 401)
            .having((error) => error.code, 'code', 'PLAT-009-003'),
      ),
    );
  });

  test('login preserves locked account error code', () async {
    final repository = _repository(
      adapter: _FakeAdapter(
        (request) => _json({
          'status': 423,
          'code': 'PLAT-009-004',
          'detail': '계정이 잠겼습니다. 잠시 후 다시 시도하세요',
        }, 423),
      ),
    );

    await expectLater(
      repository.login(email: 'locked@example.com', password: 'P@ssw0rd!'),
      throwsA(
        isA<AuthRepositoryException>()
            .having((error) => error.status, 'status', 423)
            .having((error) => error.code, 'code', 'PLAT-009-004'),
      ),
    );
  });

  test('signup posts credentials and accepts created user id', () async {
    final adapter = _FakeAdapter((request) {
      expect(request.path, '/api/v1/auth/signup');
      expect(request.data, {
        'email': 'user@example.com',
        'password': 'P@ssw0rd!',
      });
      return _json({'userId': 'user-1'}, 201);
    });
    final repository = _repository(adapter: adapter);

    await repository.signup(email: 'user@example.com', password: 'P@ssw0rd!');

    expect(adapter.requests.single.path, '/api/v1/auth/signup');
  });

  test('signup preserves duplicate email error code', () async {
    final repository = _repository(
      adapter: _FakeAdapter(
        (request) => _json({
          'status': 409,
          'code': 'PLAT-009-001',
          'detail': '이미 가입된 이메일입니다',
        }, 409),
      ),
    );

    await expectLater(
      repository.signup(email: 'user@example.com', password: 'P@ssw0rd!'),
      throwsA(
        isA<AuthRepositoryException>()
            .having((error) => error.status, 'status', 409)
            .having((error) => error.code, 'code', 'PLAT-009-001')
            .having((error) => error.detail, 'detail', '이미 가입된 이메일입니다'),
      ),
    );
  });

  test('signup maps bad password response to repository exception', () async {
    final repository = _repository(
      adapter: _FakeAdapter((request) => _json({'status': 400}, 400)),
    );

    await expectLater(
      repository.signup(email: 'user@example.com', password: 'short'),
      throwsA(
        isA<AuthRepositoryException>().having(
          (error) => error.status,
          'status',
          400,
        ),
      ),
    );
  });

  test('PLAT-001 검증 덤프 detail은 노출하지 않고 정제 메시지로 대체한다', () async {
    final repository = _repository(
      adapter: _FakeAdapter(
        (request) => _json({
          'status': 400,
          'code': 'PLAT-001',
          'detail':
              'Validation failed for argument [0] ... rejected value [...]',
        }, 400),
      ),
    );

    await expectLater(
      repository.login(email: 'user@example.com', password: 'whatever'),
      throwsA(
        isA<AuthRepositoryException>()
            .having((error) => error.code, 'code', 'PLAT-001')
            .having(
              (error) => error.detail,
              'detail',
              '입력한 정보를 다시 확인해주세요.',
            ),
      ),
    );
  });
}

OAuthRedirectService _oauthRedirectService() {
  return OAuthRedirectService(
    baseUrl: 'http://localhost:8081',
    redirect: (_) {},
  );
}

AuthRepository _repository({
  TokenStore? tokenStore,
  required _FakeAdapter adapter,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
    ..httpClientAdapter = adapter;
  return AuthRepository(
    dio: dio,
    tokenStore: tokenStore ?? InMemoryTokenStore(),
    oauthRedirectService: _oauthRedirectService(),
  );
}

ResponseBody _json(Map<String, dynamic> data, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _RecordingTokenStore implements TokenStore {
  _RecordingTokenStore({this.tokens});

  final AuthTokens? tokens;
  final calls = <String>[];

  @override
  Future<void> migrateLegacyStorage() async {
    calls.add('migrate');
  }

  @override
  Future<AuthTokens?> read() async {
    calls.add('read');
    return tokens;
  }

  @override
  Future<void> save(AuthTokens tokens) async {
    calls.add('save');
  }

  @override
  Future<void> clear() async {
    calls.add('clear');
  }
}

class _RecordedRequest {
  const _RecordedRequest({
    required this.path,
    required this.data,
    required this.headers,
  });

  final String path;
  final Object? data;
  final Map<String, dynamic> headers;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(_RecordedRequest request) _handler;
  final requests = <_RecordedRequest>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final request = _RecordedRequest(
      path: options.path,
      data: options.data,
      headers: Map<String, dynamic>.from(options.headers),
    );
    requests.add(request);
    return _handler(request);
  }

  @override
  void close({bool force = false}) {}
}
