import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final adminApiProvider = Provider<AdminApi>((ref) {
  return AdminApi(ref.watch(dioProvider));
});

class AdminApi {
  const AdminApi(this._dio);

  final Dio _dio;

  Future<AdminAnalyticsSummary> getAnalyticsSummary() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/admin/analytics/summary',
    );
    final data = response.data ?? const <String, dynamic>{};
    return AdminAnalyticsSummary.fromJson(data);
  }
}

class AdminAnalyticsSummary {
  const AdminAnalyticsSummary({
    required this.users,
    required this.tenants,
    required this.usage,
    required this.pendingItems,
    required this.recentActivities,
  });

  factory AdminAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsSummary(
      users: AdminUsersSummary.fromJson(_mapValue(json['users'])),
      tenants: AdminTenantsSummary.fromJson(_mapValue(json['tenants'])),
      usage: _listValue(json['usage'])
          .map((item) => AdminUsageItem.fromJson(_mapValue(item)))
          .toList(growable: false),
      pendingItems: _listValue(json['pendingItems'])
          .map((item) => AdminPendingItem.fromJson(_mapValue(item)))
          .toList(growable: false),
      recentActivities: _listValue(json['recentActivities'])
          .map((item) => AdminRecentActivity.fromJson(_mapValue(item)))
          .toList(growable: false),
    );
  }

  final AdminUsersSummary users;
  final AdminTenantsSummary tenants;
  final List<AdminUsageItem> usage;
  final List<AdminPendingItem> pendingItems;
  final List<AdminRecentActivity> recentActivities;
}

class AdminUsersSummary {
  const AdminUsersSummary({
    required this.total,
    required this.active,
    required this.suspended,
    required this.deleted,
    required this.newToday,
    required this.dau,
    required this.mau,
    required this.activitySource,
  });

  factory AdminUsersSummary.fromJson(Map<String, dynamic> json) {
    return AdminUsersSummary(
      total: _intValue(json['total']),
      active: _intValue(json['active']),
      suspended: _intValue(json['suspended']),
      deleted: _intValue(json['deleted']),
      newToday: _intValue(json['newToday']),
      dau: _intValue(json['dau']),
      mau: _intValue(json['mau']),
      activitySource: (json['activitySource'] as String?) ?? 'UNKNOWN',
    );
  }

  final int total;
  final int active;
  final int suspended;
  final int deleted;
  final int newToday;
  final int dau;
  final int mau;
  final String activitySource;
}

class AdminTenantsSummary {
  const AdminTenantsSummary({
    required this.total,
    required this.active,
    required this.suspended,
    required this.plans,
  });

  factory AdminTenantsSummary.fromJson(Map<String, dynamic> json) {
    final rawPlans = json['plans'];
    return AdminTenantsSummary(
      total: _intValue(json['total']),
      active: _intValue(json['active']),
      suspended: _intValue(json['suspended']),
      plans: rawPlans is Map
          ? rawPlans.map((key, value) => MapEntry('$key', _intValue(value)))
          : const <String, int>{},
    );
  }

  final int total;
  final int active;
  final int suspended;
  final Map<String, int> plans;
}

class AdminUsageItem {
  const AdminUsageItem({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.source,
  });

  factory AdminUsageItem.fromJson(Map<String, dynamic> json) {
    return AdminUsageItem(
      key: (json['key'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      value: _intValue(json['value']),
      unit: (json['unit'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'UNKNOWN',
      source: (json['source'] as String?) ?? 'UNKNOWN',
    );
  }

  final String key;
  final String label;
  final int value;
  final String unit;
  final String status;
  final String source;
}

class AdminPendingItem {
  const AdminPendingItem({
    required this.key,
    required this.label,
    required this.count,
    required this.severity,
    required this.status,
  });

  factory AdminPendingItem.fromJson(Map<String, dynamic> json) {
    return AdminPendingItem(
      key: (json['key'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      count: _intValue(json['count']),
      severity: (json['severity'] as String?) ?? 'info',
      status: (json['status'] as String?) ?? 'UNKNOWN',
    );
  }

  final String key;
  final String label;
  final int count;
  final String severity;
  final String status;
}

class AdminRecentActivity {
  const AdminRecentActivity({
    required this.action,
    required this.userId,
    required this.resourceType,
    required this.resourceId,
    required this.createdAt,
  });

  factory AdminRecentActivity.fromJson(Map<String, dynamic> json) {
    return AdminRecentActivity(
      action: (json['action'] as String?) ?? '',
      userId: json['userId'] as String?,
      resourceType: json['resourceType'] as String?,
      resourceId: json['resourceId'] as String?,
      createdAt: _dateTimeValue(json['createdAt']),
    );
  }

  final String action;
  final String? userId;
  final String? resourceType;
  final String? resourceId;
  final DateTime? createdAt;
}

Map<String, dynamic> _mapValue(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return const <String, dynamic>{};
}

List<dynamic> _listValue(Object? value) => value is List ? value : const [];

int _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}

DateTime? _dateTimeValue(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
