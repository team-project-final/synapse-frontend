import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final platformAuthApiProvider = Provider<PlatformAuthApi>((ref) {
  return PlatformAuthApi(ref.watch(dioProvider));
});

class MfaSetupResult {
  const MfaSetupResult({required this.otpAuthUri, required this.secret});

  final String otpAuthUri;
  final String secret;
}

class PasswordResetVerification {
  const PasswordResetVerification({
    required this.resetToken,
    required this.expiresAt,
  });

  final String resetToken;
  final DateTime expiresAt;
}

class PlatformAuthApi {
  const PlatformAuthApi(this._dio);

  final Dio _dio;

  Future<bool> requestPasswordReset(String email) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/password-reset/request',
      data: {'email': email},
    );
    final accepted = response.data?['accepted'];

    if (accepted is! bool) {
      throw const FormatException('Invalid password reset request response.');
    }

    return accepted;
  }

  Future<PasswordResetVerification> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/password-reset/verify',
      data: {'email': email, 'code': code},
    );
    final resetToken = response.data?['resetToken'];
    final expiresAt = response.data?['expiresAt'];

    if (resetToken is! String || expiresAt is! String) {
      throw const FormatException('Invalid password reset verify response.');
    }

    return PasswordResetVerification(
      resetToken: resetToken,
      expiresAt: DateTime.parse(expiresAt),
    );
  }

  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      '/api/v1/auth/password-reset/confirm',
      data: {'resetToken': resetToken, 'newPassword': newPassword},
    );
  }

  Future<MfaSetupResult> setupMfa() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/mfa/setup',
    );
    final data = response.data ?? <String, dynamic>{};
    final otpAuthUri = data['otpAuthUri'];
    final secret = data['secret'];

    if (otpAuthUri is! String || secret is! String) {
      throw const FormatException('Invalid MFA setup response.');
    }

    return MfaSetupResult(otpAuthUri: otpAuthUri, secret: secret);
  }

  Future<bool> verifyMfa(String code) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/mfa/verify',
      data: {'code': code},
    );
    final verified = response.data?['verified'];

    if (verified is! bool) {
      throw const FormatException('Invalid MFA verify response.');
    }

    return verified;
  }
}
