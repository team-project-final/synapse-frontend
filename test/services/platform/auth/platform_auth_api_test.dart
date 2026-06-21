import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';

void main() {
  test('requestPasswordReset sends email and maps accepted flag', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/password-reset/request');
        expect(options.data, {'email': 'user@example.com'});
        return ResponseBody.fromString(
          jsonEncode({'accepted': true}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final accepted = await api.requestPasswordReset('user@example.com');

    expect(accepted, isTrue);
  });

  test('verifyPasswordReset sends code and maps reset token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/password-reset/verify');
        expect(options.data, {'email': 'user@example.com', 'code': '123456'});
        return ResponseBody.fromString(
          jsonEncode({
            'resetToken': 'reset-token',
            'expiresAt': '2026-06-21T09:30:00Z',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final verification = await api.verifyPasswordReset(
      email: 'user@example.com',
      code: '123456',
    );

    expect(verification.resetToken, 'reset-token');
    expect(verification.expiresAt, DateTime.utc(2026, 6, 21, 9, 30));
  });

  test('confirmPasswordReset sends reset token and new password', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/password-reset/confirm');
        expect(options.data, {
          'resetToken': 'reset-token',
          'newPassword': 'N3wP@ssword!',
        });
        return ResponseBody.fromString('', 204);
      });
    final api = PlatformAuthApi(dio);

    await api.confirmPasswordReset(
      resetToken: 'reset-token',
      newPassword: 'N3wP@ssword!',
    );
  });

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

  test('generateMfaBackupCodes maps backup code list', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/mfa/backup-codes');
        return ResponseBody.fromString(
          jsonEncode({
            'codes': ['ABCD-EFGH', 'IJKL-MNOP'],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final codes = await api.generateMfaBackupCodes();

    expect(codes, ['ABCD-EFGH', 'IJKL-MNOP']);
  });

  test('verifyMfaBackupCode sends code and returns verified flag', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/auth/mfa/backup');
        expect(options.data, {'code': 'ABCD-EFGH'});
        return ResponseBody.fromString(
          jsonEncode({'verified': true}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = PlatformAuthApi(dio);

    final verified = await api.verifyMfaBackupCode('ABCD-EFGH');

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
