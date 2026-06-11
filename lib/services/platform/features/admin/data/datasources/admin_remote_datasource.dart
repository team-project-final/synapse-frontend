import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/models/admin_analytics_summary_model.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/models/admin_data_request_model.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/models/admin_settings_model.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_data_request.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_settings.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/models/admin_audit_log_model.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/models/admin_page_model.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/models/admin_tenant_model.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/models/admin_user_model.dart';

/// platform-svc 관리자 API 원격 데이터소스.
class AdminRemoteDatasource {
  const AdminRemoteDatasource(this._dio);
  final Dio _dio;

  Future<AdminPageModel<AdminUserModel>> listUsers({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/admin/users',
      queryParameters: _queryParameters({
        'q': query,
        'status': status,
        'page': page,
        'size': size,
      }),
    );
    return AdminPageModel.fromJson(
      response.data ?? const <String, dynamic>{},
      AdminUserModel.fromJson,
    );
  }

  Future<void> changeUserStatus(String id, String status) async {
    await _dio.put<void>(
      '/api/v1/admin/users/$id/status',
      data: {'status': status.toLowerCase()},
    );
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete<void>('/api/v1/admin/users/$id');
  }

  Future<AdminPageModel<AdminTenantModel>> listTenants({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/admin/tenants',
      queryParameters: {'page': page, 'size': size},
    );
    return AdminPageModel.fromJson(
      response.data ?? const <String, dynamic>{},
      AdminTenantModel.fromJson,
    );
  }

  Future<void> changeTenantStatus(String id, String status) async {
    await _dio.put<void>(
      '/api/v1/admin/tenants/$id/status',
      data: {'status': status.toLowerCase()},
    );
  }

  Future<AdminPageModel<AdminAuditLogModel>> listAuditLogs({
    String? action,
    String? userId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/admin/audit-logs',
      queryParameters: _queryParameters({
        'action': action,
        'userId': userId,
        'page': page,
        'size': size,
      }),
    );
    return AdminPageModel.fromJson(
      response.data ?? const <String, dynamic>{},
      AdminAuditLogModel.fromJson,
    );
  }

  Future<AdminAnalyticsSummaryModel> getAnalyticsSummary() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/admin/analytics/summary',
    );
    return AdminAnalyticsSummaryModel.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<AdminSettingsModel> getSettings() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/admin/settings',
    );
    return AdminSettingsModel.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<AdminSettingsModel> updateSettings(AdminSettingsUpdate update) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/admin/settings',
      data: adminSettingsUpdateToJson(update),
    );
    return AdminSettingsModel.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<AdminPageModel<AdminDataRequestModel>> listDataRequests({
    String? status,
    String? query,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/admin/data-requests',
      queryParameters: _queryParameters({
        'status': status,
        'q': query,
        'page': page,
        'size': size,
      }),
    );
    return AdminPageModel.fromJson(
      response.data ?? const <String, dynamic>{},
      AdminDataRequestModel.fromJson,
    );
  }

  Future<AdminDataRequestModel> createDataRequest({
    required String userId,
    required String type,
    String? reason,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/admin/data-requests',
      data: {
        'userId': userId,
        'type': type,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    return AdminDataRequestModel.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<AdminDataRequestModel> applyDataRequestAction({
    required String id,
    required String action,
    String? reason,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/admin/data-requests/$id/actions',
        data: {
          'action': action,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      return AdminDataRequestModel.fromJson(
        response.data ?? const <String, dynamic>{},
      );
    } on DioException catch (error) {
      // 409 = 다른 관리자가 먼저 처리했거나 허용되지 않는 전이(예: ERASURE 즉시 실행).
      if (error.response?.statusCode == 409) {
        throw const AdminDataRequestConflictException(
          '요청 상태가 변경되어 처리할 수 없습니다. 목록을 새로고침해주세요.',
        );
      }
      rethrow;
    }
  }
}

Map<String, dynamic> _queryParameters(Map<String, Object?> values) {
  return {
    for (final entry in values.entries)
      if (entry.value != null && entry.value.toString().isNotEmpty)
        entry.key: entry.value,
  };
}
