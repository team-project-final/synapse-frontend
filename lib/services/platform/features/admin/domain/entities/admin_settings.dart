/// `GET/PUT /api/v1/admin/settings` 도메인 엔티티.
///
/// 플랜 쿼터는 조회 전용이고, 수정 가능한 것은 피처 플래그와 레이트리밋뿐이다
/// (백엔드 AdminSettingsUpdateRequest에 planQuotas 없음).
class AdminSettings {
  const AdminSettings({
    required this.planQuotas,
    required this.featureFlags,
    required this.rateLimitPerMinute,
    this.updatedAt,
  });

  final List<AdminPlanQuota> planQuotas;
  final List<AdminFeatureFlag> featureFlags;
  final int rateLimitPerMinute;
  final DateTime? updatedAt;
}

/// 플랜별 쿼터. null은 무제한을 뜻한다.
class AdminPlanQuota {
  const AdminPlanQuota({
    required this.planCode,
    required this.displayName,
    this.maxNotes,
    this.maxCards,
    this.maxStorageBytes,
    this.maxAiTokensMonthly,
    this.maxAiCardGenerationsMonthly,
    this.maxUsersPerTenant,
  });

  final String planCode;
  final String displayName;
  final int? maxNotes;
  final int? maxCards;
  final int? maxStorageBytes;
  final int? maxAiTokensMonthly;
  final int? maxAiCardGenerationsMonthly;
  final int? maxUsersPerTenant;
}

class AdminFeatureFlag {
  const AdminFeatureFlag({
    required this.key,
    required this.label,
    required this.enabled,
  });

  final String key;
  final String label;
  final bool enabled;

  AdminFeatureFlag copyWith({bool? enabled}) {
    return AdminFeatureFlag(
      key: key,
      label: label,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// PUT 요청 페이로드(수정 가능한 항목만).
class AdminSettingsUpdate {
  const AdminSettingsUpdate({
    required this.featureFlags,
    required this.rateLimitPerMinute,
  });

  final List<AdminFeatureFlag> featureFlags;
  final int rateLimitPerMinute;
}
