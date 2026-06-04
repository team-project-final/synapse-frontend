import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';

void main() {
  test('setupMfa maps otp auth URI and secret', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/mfa/setup');
        return ResponseBody.fromString(
          jsonEncode({
            'otpAuthUri': 'otpauth://totp/Synapse:user@example.com',
            'secret': 'BASE32SECRET',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final result = await api.setupMfa();

    expect(result.otpAuthUri, 'otpauth://totp/Synapse:user@example.com');
    expect(result.secret, 'BASE32SECRET');
  });

  test('verifyMfa sends code and returns verified flag', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/mfa/verify');
        return ResponseBody.fromString(
          jsonEncode({'verified': true}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final verified = await api.verifyMfa('123456');

    expect(verified, isTrue);
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
