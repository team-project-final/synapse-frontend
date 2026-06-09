import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final accountApiProvider = Provider<AccountApi>((ref) {
  return AccountApi(ref.watch(dioProvider));
});

/// platform-svc user 셀프서비스 호출 실패를 화면이 다루기 쉬운 형태로 변환한 예외.
class AccountApiException implements Exception {
  const AccountApiException({
    required this.status,
    required this.message,
    this.code,
  });

  final int status;
  final String? code;
  final String message;

  @override
  String toString() => 'AccountApiException($status, $code, $message)';
}

/// platform-svc `/api/v1/users/me` 셀프서비스 API 클라이언트.
class AccountApi {
  const AccountApi(this._dio);

  final Dio _dio;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put<void>(
        '/api/v1/users/me/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (error) {
      throw _mapException(error, '비밀번호 변경에 실패했습니다.');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete<void>('/api/v1/users/me');
    } on DioException catch (error) {
      throw _mapException(error, '계정 삭제에 실패했습니다.');
    }
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/users/me');
      return UserProfile.fromJson(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw _mapException(error, '프로필을 불러오지 못했습니다.');
    }
  }

  Future<UserProfile> updateProfile({
    required String displayName,
    required String language,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/v1/users/me',
        data: {'displayName': displayName, 'language': language},
      );
      return UserProfile.fromJson(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw _mapException(error, '프로필 저장에 실패했습니다.');
    }
  }

  Future<List<OAuthConnection>> listOAuthConnections() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/v1/users/me/oauth');
      final data = response.data ?? const <dynamic>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(OAuthConnection.fromJson)
          .toList();
    } on DioException catch (error) {
      throw _mapException(error, '연결된 계정을 불러오지 못했습니다.');
    }
  }

  Future<void> unlinkOAuth(String provider) async {
    try {
      await _dio.delete<void>('/api/v1/users/me/oauth/$provider');
    } on DioException catch (error) {
      throw _mapException(error, '연결 해제에 실패했습니다.');
    }
  }

  AccountApiException _mapException(DioException error, String fallback) {
    final response = error.response;
    final status = response?.statusCode ?? 0;
    final data = response?.data;
    final code = data is Map<String, dynamic> && data['code'] is String
        ? data['code'] as String
        : null;
    return AccountApiException(
      status: status,
      code: code,
      message: _message(status, code, fallback),
    );
  }

  String _message(int status, String? code, String fallback) {
    return switch (code) {
      'PLAT-USER-002' => '현재 비밀번호가 올바르지 않습니다.',
      'PLAT-USER-001' => '비밀번호 로그인이 설정되지 않은 계정입니다.',
      'PLAT-OAUTH-002' => '마지막 로그인 수단은 해제할 수 없습니다.',
      'PLAT-OAUTH-001' => '연결된 계정을 찾을 수 없습니다.',
      _ => status == 401 ? '인증이 만료되었습니다. 다시 로그인해주세요.' : fallback,
    };
  }
}

/// `GET /api/v1/users/me` 응답. 셀프서비스 프로필 + 비밀번호 로그인 보유 여부.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.hasPassword,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.language,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      hasPassword: json['hasPassword'] as bool? ?? false,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      language: json['language'] as String?,
    );
  }

  final String id;
  final bool hasPassword;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String? language;
}

/// `GET /api/v1/users/me/oauth` 항목.
class OAuthConnection {
  const OAuthConnection({required this.provider, this.email});

  factory OAuthConnection.fromJson(Map<String, dynamic> json) {
    return OAuthConnection(
      provider: json['provider'] as String? ?? '',
      email: json['email'] as String?,
    );
  }

  final String provider;
  final String? email;
}
