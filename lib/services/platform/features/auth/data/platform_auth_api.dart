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

/// `POST /auth/password-reset/verify` 응답. confirm 단계에서 사용할 토큰.
class PasswordResetVerifyResult {
  const PasswordResetVerifyResult({required this.resetToken, this.expiresAt});

  final String resetToken;
  final DateTime? expiresAt;
}

/// platform-svc auth 호출 실패를 화면이 다루기 쉬운 형태로 변환한 예외.
class PlatformAuthApiException implements Exception {
  const PlatformAuthApiException({
    required this.status,
    required this.message,
    this.code,
  });

  final int status;
  final String? code;
  final String message;

  @override
  String toString() => 'PlatformAuthApiException($status, $code, $message)';
}

class PlatformAuthApi {
  const PlatformAuthApi(this._dio);

  final Dio _dio;

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

  /// 백업 코드 발급. 기존 미사용 코드는 백엔드에서 전부 무효화된 뒤 새로 발급된다.
  Future<List<String>> generateMfaBackupCodes() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/mfa/backup-codes',
      );
      final codes = response.data?['codes'];
      if (codes is! List) {
        throw const FormatException('Invalid MFA backup codes response.');
      }
      return codes.whereType<String>().toList();
    } on DioException catch (error) {
      throw _mapException(error, '백업 코드를 발급하지 못했습니다.');
    }
  }

  Future<bool> verifyMfaBackupCode(String code) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/mfa/backup',
      data: {'code': code},
    );
    final verified = response.data?['verified'];

    if (verified is! bool) {
      throw const FormatException('Invalid MFA backup verify response.');
    }

    return verified;
  }

  /// 재설정 코드 발송 요청. 이메일 존재 여부와 무관하게 성공 응답이 온다(열거 방지).
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/password-reset/request',
        data: {'email': email},
      );
    } on DioException catch (error) {
      throw _mapException(error, '인증 코드 발송에 실패했습니다.');
    }
  }

  Future<PasswordResetVerifyResult> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/password-reset/verify',
        data: {'email': email, 'code': code},
      );
      final resetToken = response.data?['resetToken'];
      if (resetToken is! String || resetToken.isEmpty) {
        throw const FormatException('Invalid password reset verify response.');
      }
      final expiresAt = response.data?['expiresAt'];
      return PasswordResetVerifyResult(
        resetToken: resetToken,
        expiresAt: expiresAt is String ? DateTime.tryParse(expiresAt) : null,
      );
    } on DioException catch (error) {
      throw _mapException(error, '인증 코드 확인에 실패했습니다.');
    }
  }

  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _dio.post<void>(
        '/api/v1/auth/password-reset/confirm',
        data: {'resetToken': resetToken, 'newPassword': newPassword},
      );
    } on DioException catch (error) {
      throw _mapException(error, '비밀번호 변경에 실패했습니다.');
    }
  }

  PlatformAuthApiException _mapException(DioException error, String fallback) {
    final response = error.response;
    final status = response?.statusCode ?? 0;
    final data = response?.data;
    final code = data is Map<String, dynamic> && data['code'] is String
        ? data['code'] as String
        : null;
    return PlatformAuthApiException(
      status: status,
      code: code,
      message: _message(status, code, fallback),
    );
  }

  String _message(int status, String? code, String fallback) {
    return switch (code) {
      // 백엔드는 코드 불일치/만료/시도 초과를 모두 PLAT-AUTH-070 하나로 응답한다(열거 방지).
      'PLAT-AUTH-070' => '인증 코드가 올바르지 않거나 만료되었습니다. 처음부터 다시 시도해주세요.',
      'PLAT-003' => 'MFA가 활성화되어 있지 않거나 코드가 올바르지 않습니다.',
      _ => status == 401 ? '인증이 만료되었습니다. 다시 로그인해주세요.' : fallback,
    };
  }
}
