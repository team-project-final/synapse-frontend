/// `GET /api/v1/admin/analytics/summary` 도메인 엔티티.
class AdminAnalyticsSummary {
  const AdminAnalyticsSummary({
    required this.users,
    required this.tenants,
    required this.usage,
    required this.pendingItems,
    required this.recentActivities,
    this.generatedAt,
  });

  final DateTime? generatedAt;
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

  final int total;
  final int active;
  final int suspended;

  /// 플랜 키(free/pro 등) → 테넌트 수.
  final Map<String, int> plans;
}

/// usage/pending 항목의 연결 상태. 백엔드가 타 서비스 정본 값은
/// fake 대신 NOT_CONNECTED/NOT_IMPLEMENTED로 내려준다.
enum AdminMetricStatus {
  ok,
  notConnected,
  notImplemented;

  static AdminMetricStatus parse(String? raw) {
    return switch (raw) {
      'OK' || 'INFO' => AdminMetricStatus.ok,
      'NOT_IMPLEMENTED' => AdminMetricStatus.notImplemented,
      _ => AdminMetricStatus.notConnected,
    };
  }
}

class AdminUsageItem {
  const AdminUsageItem({
    required this.key,
    required this.label,
    required this.unit,
    required this.status,
    required this.source,
    this.value,
  });

  final String key;
  final String label;
  final int? value;
  final String unit;
  final AdminMetricStatus status;
  final String source;
}

class AdminPendingItem {
  const AdminPendingItem({
    required this.key,
    required this.label,
    required this.severity,
    required this.status,
    this.count,
  });

  final String key;
  final String label;
  final int? count;
  final String severity;
  final AdminMetricStatus status;
}

class AdminRecentActivity {
  const AdminRecentActivity({
    required this.id,
    required this.action,
    required this.userId,
    required this.resourceType,
    required this.resourceId,
    this.createdAt,
  });

  final String id;
  final String action;
  final String userId;
  final String resourceType;
  final String resourceId;
  final DateTime? createdAt;
}
