import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_data_request.dart';

/// platform-svc AdminDataRequestResponse(JSON) DTO.
class AdminDataRequestModel {
  const AdminDataRequestModel(this._json);

  factory AdminDataRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminDataRequestModel(json);
  }

  final Map<String, dynamic> _json;

  AdminDataRequest toEntity() {
    return AdminDataRequest(
      id: _string(_json['id']),
      userId: _string(_json['userId']),
      userEmail: _string(_json['userEmail']),
      userDisplayName: _string(_json['userDisplayName']),
      type: AdminDataRequestType.parse(_json['type']?.toString()),
      typeLabel: _string(_json['typeLabel']),
      status: AdminDataRequestStatus.parse(_json['status']?.toString()),
      statusLabel: _string(_json['statusLabel']),
      receivedAt: _date(_json['receivedAt']),
      dueAt: _date(_json['dueAt']),
      daysRemaining: (_json['daysRemaining'] as num?)?.toInt() ?? 0,
      processedAt: _date(_json['processedAt']),
      reason: _json['reason'] as String?,
      adminNote: _json['adminNote'] as String?,
      dataSummary: _json['dataSummary'] as String?,
      latestLog: _json['latestLog'] as String?,
      executionLogs: (_json['executionLogs'] as List? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

String _string(Object? value) => value?.toString() ?? '';

DateTime? _date(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }
  return null;
}
