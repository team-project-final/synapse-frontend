import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_analytics_summary.dart';

/// platform-svc AdminAnalyticsSummaryResponse(JSON) DTO.
class AdminAnalyticsSummaryModel {
  const AdminAnalyticsSummaryModel(this._json);

  factory AdminAnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsSummaryModel(json);
  }

  final Map<String, dynamic> _json;

  AdminAnalyticsSummary toEntity() {
    final users = _map(_json['users']);
    final tenants = _map(_json['tenants']);
    return AdminAnalyticsSummary(
      generatedAt: _date(_json['generatedAt']),
      users: AdminUsersSummary(
        total: _int(users['total']),
        active: _int(users['active']),
        suspended: _int(users['suspended']),
        deleted: _int(users['deleted']),
        newToday: _int(users['newToday']),
        dau: _int(users['dau']),
        mau: _int(users['mau']),
        activitySource: _string(users['activitySource']),
      ),
      tenants: AdminTenantsSummary(
        total: _int(tenants['total']),
        active: _int(tenants['active']),
        suspended: _int(tenants['suspended']),
        plans: {
          for (final entry in _map(tenants['plans']).entries)
            entry.key: _int(entry.value),
        },
      ),
      usage: _list(_json['usage'])
          .map(
            (item) => AdminUsageItem(
              key: _string(item['key']),
              label: _string(item['label']),
              value: _intOrNull(item['value']),
              unit: _string(item['unit']),
              status: AdminMetricStatus.parse(item['status']?.toString()),
              source: _string(item['source']),
            ),
          )
          .toList(),
      pendingItems: _list(_json['pendingItems'])
          .map(
            (item) => AdminPendingItem(
              key: _string(item['key']),
              label: _string(item['label']),
              count: _intOrNull(item['count']),
              severity: _string(item['severity']),
              status: AdminMetricStatus.parse(item['status']?.toString()),
            ),
          )
          .toList(),
      recentActivities: _list(_json['recentActivities'])
          .map(
            (item) => AdminRecentActivity(
              id: _string(item['id']),
              action: _string(item['action']),
              userId: _string(item['userId']),
              resourceType: _string(item['resourceType']),
              resourceId: _string(item['resourceId']),
              createdAt: _date(item['createdAt']),
            ),
          )
          .toList(),
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  return value is Map<String, dynamic> ? value : const <String, dynamic>{};
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}

int _int(Object? value) => _intOrNull(value) ?? 0;

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

String _string(Object? value) => value?.toString() ?? '';

DateTime? _date(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
