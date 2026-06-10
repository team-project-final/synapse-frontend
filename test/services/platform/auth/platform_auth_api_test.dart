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

  test('generateMfaBackupCodes returns issued codes', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/mfa/backup-codes');
        return ResponseBody.fromString(
          jsonEncode({
            'codes': ['AAAA-1111', 'BBBB-2222'],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final codes = await api.generateMfaBackupCodes();

    expect(codes, ['AAAA-1111', 'BBBB-2222']);
  });

  test('verifyMfaBackupCode sends code and returns verified flag', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/mfa/backup');
        return ResponseBody.fromString(
          jsonEncode({'verified': true}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final verified = await api.verifyMfaBackupCode('AAAA-1111');

    expect(verified, isTrue);
  });

  test('requestPasswordReset posts email', () async {
    late Map<String, dynamic> sentBody;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/password-reset/request');
        sentBody = options.data as Map<String, dynamic>;
        return ResponseBody.fromString(
          jsonEncode({'accepted': true}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    await api.requestPasswordReset('user@example.com');

    expect(sentBody, {'email': 'user@example.com'});
  });

  test('verifyPasswordReset returns reset token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/password-reset/verify');
        return ResponseBody.fromString(
          jsonEncode({
            'resetToken': 'reset-token',
            'expiresAt': '2026-06-10T12:00:00Z',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final result = await api.verifyPasswordReset(
      email: 'user@example.com',
      code: '123456',
    );

    expect(result.resetToken, 'reset-token');
    expect(result.expiresAt, DateTime.parse('2026-06-10T12:00:00Z'));
  });

  test('verifyPasswordReset maps PLAT-AUTH-070 to Korean message', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': 400,
            'code': 'PLAT-AUTH-070',
            'detail': 'Password reset code is invalid or expired.',
          }),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    await expectLater(
      api.verifyPasswordReset(email: 'user@example.com', code: '000000'),
      throwsA(
        isA<PlatformAuthApiException>()
            .having((e) => e.code, 'code', 'PLAT-AUTH-070')
            .having((e) => e.message, 'message', contains('인증 코드')),
      ),
    );
  });

  test('confirmPasswordReset posts reset token and new password', () async {
    late Map<String, dynamic> sentBody;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/password-reset/confirm');
        sentBody = options.data as Map<String, dynamic>;
        return ResponseBody.fromString('', 204);
      });
    final api = PlatformAuthApi(dio);

    await api.confirmPasswordReset(
      resetToken: 'reset-token',
      newPassword: 'P@ssw0rd!',
    );

    expect(sentBody, {'resetToken': 'reset-token', 'newPassword': 'P@ssw0rd!'});
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
