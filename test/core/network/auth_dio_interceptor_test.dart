import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/network/auth_dio_interceptor.dart';

void main() {
  test('adds bearer token to protected requests', () async {
    final tokenStore = InMemoryTokenStore();
    await tokenStore.save(
      const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    );
    final adapter = _FakeAdapter((request) {
      return ResponseBody.fromString('ok', 200);
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthDioInterceptor(tokenStore: tokenStore, refreshDio: dio),
    );

    await dio.get<void>('/api/v1/billing/subscription');

    expect(adapter.requests.single.headers['Authorization'], 'Bearer access');
  });

  test('refreshes tokens and retries once after 401', () async {
    final tokenStore = InMemoryTokenStore();
    await tokenStore.save(
      const AuthTokens(accessToken: 'old-access', refreshToken: 'old-refresh'),
    );
    var protectedAttempts = 0;
    final adapter = _FakeAdapter((request) {
      if (request.path == '/api/v1/billing/subscription') {
        protectedAttempts += 1;
        if (protectedAttempts == 1) {
          return ResponseBody.fromString('unauthorized', 401);
        }
        return ResponseBody.fromString('ok', 200);
      }
      if (request.path == '/api/v1/auth/refresh') {
        return ResponseBody.fromString(
          jsonEncode({
            'accessToken': 'new-access',
            'refreshToken': 'new-refresh',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString('not found', 404);
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = adapter;
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthDioInterceptor(tokenStore: tokenStore, refreshDio: refreshDio),
    );

    final response = await dio.get<String>('/api/v1/billing/subscription');

    final tokens = await tokenStore.read();
    final protectedRequests = adapter.requests
        .where((request) => request.path == '/api/v1/billing/subscription')
        .toList();
    expect(response.statusCode, 200);
    expect(tokens?.accessToken, 'new-access');
    expect(tokens?.refreshToken, 'new-refresh');
    expect(protectedRequests, hasLength(2));
    expect(
      protectedRequests.first.headers['Authorization'],
      'Bearer old-access',
    );
    expect(
      protectedRequests.last.headers['Authorization'],
      'Bearer new-access',
    );
  });
}

class _RecordedRequest {
  const _RecordedRequest({required this.path, required this.headers});

  final String path;
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
      headers: Map<String, dynamic>.from(options.headers),
    );
    requests.add(request);
    return _handler(request);
  }

  @override
  void close({bool force = false}) {}
}
