import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_settings.dart';

/// platform-svc AdminSettingsResponse(JSON) DTO.
class AdminSettingsModel {
  const AdminSettingsModel(this._json);

  factory AdminSettingsModel.fromJson(Map<String, dynamic> json) {
    return AdminSettingsModel(json);
  }

  final Map<String, dynamic> _json;

  AdminSettings toEntity() {
    final rateLimit = _map(_json['rateLimit']);
    return AdminSettings(
      planQuotas: _list(_json['planQuotas'])
          .map(
            (item) => AdminPlanQuota(
              planCode: _string(item['planCode']),
              displayName: _string(item['displayName']),
              maxNotes: _intOrNull(item['maxNotes']),
              maxCards: _intOrNull(item['maxCards']),
              maxStorageBytes: _intOrNull(item['maxStorageBytes']),
              maxAiTokensMonthly: _intOrNull(item['maxAiTokensMonthly']),
              maxAiCardGenerationsMonthly:
                  _intOrNull(item['maxAiCardGenerationsMonthly']),
              maxUsersPerTenant: _intOrNull(item['maxUsersPerTenant']),
            ),
          )
          .toList(),
      featureFlags: _list(_json['featureFlags'])
          .map(
            (item) => AdminFeatureFlag(
              key: _string(item['key']),
              label: _string(item['label']),
              enabled: item['enabled'] as bool? ?? false,
            ),
          )
          .toList(),
      rateLimitPerMinute: _intOrNull(rateLimit['apiRequestsPerMinute']) ?? 0,
      updatedAt: _date(_json['updatedAt']),
    );
  }
}

/// AdminSettingsUpdateRequest(JSON) 직렬화.
Map<String, dynamic> adminSettingsUpdateToJson(AdminSettingsUpdate update) {
  return {
    'featureFlags': [
      for (final flag in update.featureFlags)
        {'key': flag.key, 'enabled': flag.enabled},
    ],
    'rateLimit': {'apiRequestsPerMinute': update.rateLimitPerMinute},
  };
}

Map<String, dynamic> _map(Object? value) {
  return value is Map<String, dynamic> ? value : const <String, dynamic>{};
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}

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
