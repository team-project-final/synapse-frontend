import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/models/admin_analytics_summary_model.dart';
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
}

Map<String, dynamic> _queryParameters(Map<String, Object?> values) {
  return {
    for (final entry in values.entries)
      if (entry.value != null && entry.value.toString().isNotEmpty)
        entry.key: entry.value,
  };
}
