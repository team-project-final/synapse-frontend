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
}
