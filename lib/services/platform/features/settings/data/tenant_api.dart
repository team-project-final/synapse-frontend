import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final tenantApiProvider = Provider<TenantApi>((ref) {
  return TenantApi(ref.watch(dioProvider));
});

/// 백엔드 역할 코드(owner/admin/member/viewer) → 표시 라벨.
String tenantRoleLabel(String role) {
  return switch (role) {
    'owner' => '소유자',
    'admin' => '관리자',
    'member' => '멤버',
    'viewer' => '뷰어',
    _ => role,
  };
}

class TenantApiException implements Exception {
  const TenantApiException({
    required this.status,
    required this.message,
    this.code,
  });

  final int status;
  final String? code;
  final String message;

  @override
  String toString() => 'TenantApiException($status, $code, $message)';
}

class TenantInfo {
  const TenantInfo({
    required this.id,
    required this.name,
    required this.myRole,
    this.slug,
    this.plan,
    this.status,
    this.region,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      myRole: json['myRole'] as String? ?? '',
      slug: json['slug'] as String?,
      plan: json['plan'] as String?,
      status: json['status'] as String?,
      region: json['region'] as String?,
    );
  }

  final String id;
  final String name;
  final String myRole;
  final String? slug;
  final String? plan;
  final String? status;
  final String? region;

  /// 테넌트 관리(수정/초대/멤버 관리) 권한 보유 여부.
  bool get isManager => myRole == 'owner' || myRole == 'admin';
}

class TenantMember {
  const TenantMember({
    required this.userId,
    required this.role,
    this.email,
    this.displayName,
  });

  factory TenantMember.fromJson(Map<String, dynamic> json) {
    return TenantMember(
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
    );
  }

  final String userId;
  final String role;
  final String? email;
  final String? displayName;
}

class TenantMemberPage {
  const TenantMemberPage({
    required this.items,
    required this.page,
    required this.totalElements,
    required this.totalPages,
  });

  final List<TenantMember> items;
  final int page;
  final int totalElements;
  final int totalPages;
}

class TenantInvitation {
  const TenantInvitation({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });

  factory TenantInvitation.fromJson(Map<String, dynamic> json) {
    return TenantInvitation(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  final String id;
  final String email;
  final String role;
  final String status;
}

/// platform-svc `/api/v1/tenants` 셀프서비스 API 클라이언트.
class TenantApi {
  const TenantApi(this._dio);

  final Dio _dio;

  Future<TenantInfo> getMyTenant() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/tenants/me',
      );
      return TenantInfo.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _map(error, '테넌트 정보를 불러오지 못했습니다.');
    }
  }

  Future<TenantInfo> updateMyTenant({required String name}) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/v1/tenants/me',
        data: {'name': name},
      );
      return TenantInfo.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _map(error, '테넌트 정보 저장에 실패했습니다.');
    }
  }

  Future<TenantMemberPage> listMembers({int page = 0, int size = 50}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/tenants/me/members',
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data ?? const <String, dynamic>{};
      final items = (data['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TenantMember.fromJson)
          .toList();
      return TenantMemberPage(
        items: items,
        page: (data['page'] as num?)?.toInt() ?? 0,
        totalElements: (data['totalElements'] as num?)?.toInt() ?? items.length,
        totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
      );
    } on DioException catch (error) {
      throw _map(error, '멤버 목록을 불러오지 못했습니다.');
    }
  }

  Future<TenantMember> updateMemberRole(String userId, String role) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/v1/tenants/me/members/$userId',
        data: {'role': role},
      );
      return TenantMember.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _map(error, '역할 변경에 실패했습니다.');
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      await _dio.delete<void>('/api/v1/tenants/me/members/$userId');
    } on DioException catch (error) {
      throw _map(error, '멤버 삭제에 실패했습니다.');
    }
  }

  Future<TenantInvitation> createInvitation({
    required String email,
    required String role,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/tenants/me/invitations',
        data: {'email': email, 'role': role},
      );
      return TenantInvitation.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _map(error, '초대 전송에 실패했습니다.');
    }
  }

  TenantApiException _map(DioException error, String fallback) {
    final response = error.response;
    final status = response?.statusCode ?? 0;
    final data = response?.data;
    final code = data is Map<String, dynamic> && data['code'] is String
        ? data['code'] as String
        : null;
    return TenantApiException(
      status: status,
      code: code,
      message: _message(code, fallback),
    );
  }

  String _message(String? code, String fallback) {
    return switch (code) {
      'PLAT-TENANT-004' => '테넌트 관리 권한이 필요합니다.',
      'PLAT-TENANT-005' => '잘못된 역할입니다.',
      'PLAT-TENANT-006' => '본인 멤버십은 변경할 수 없습니다.',
      'PLAT-TENANT-007' => '마지막 소유자는 삭제할 수 없습니다.',
      'PLAT-TENANT-008' => '멤버를 찾을 수 없습니다.',
      'PLAT-TENANT-009' => '테넌트 이름을 입력해주세요.',
      'PLAT-TENANT-011' => '소유자 역할은 변경할 수 없습니다.',
      'PLAT-TENANT-012' => '소유자는 관리할 수 없습니다.',
      'PLAT-TENANT-013' => '올바른 이메일 형식이 아닙니다.',
      'PLAT-TENANT-014' => '이미 이 테넌트의 멤버입니다.',
      'PLAT-TENANT-015' => '이미 초대가 발송되어 있습니다.',
      _ => fallback,
    };
  }
}
