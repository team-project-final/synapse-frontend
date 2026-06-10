import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_audit_log.dart';

/// platform-svc AuditLogResponse(JSON) DTO.
class AdminAuditLogModel {
  const AdminAuditLogModel({
    required this.id,
    required this.eventId,
    required this.action,
    required this.userId,
    required this.resourceType,
    required this.resourceId,
    required this.oldValue,
    required this.newValue,
    required this.ipAddress,
    required this.userAgent,
    this.createdAt,
  });

  factory AdminAuditLogModel.fromJson(Map<String, dynamic> json) {
    String str(Object? v) => v?.toString() ?? '';
    return AdminAuditLogModel(
      id: str(json['id']),
      eventId: str(json['eventId']),
      action: json['action']?.toString() ?? 'UNKNOWN',
      userId: str(json['userId']),
      resourceType: str(json['resourceType']),
      resourceId: str(json['resourceId']),
      oldValue: str(json['oldValue']),
      newValue: str(json['newValue']),
      ipAddress: str(json['ipAddress']),
      userAgent: str(json['userAgent']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  final String id;
  final String eventId;
  final String action;
  final String userId;
  final String resourceType;
  final String resourceId;
  final String oldValue;
  final String newValue;
  final String ipAddress;
  final String userAgent;
  final DateTime? createdAt;

  AdminAuditLog toEntity() => AdminAuditLog(
        id: id,
        eventId: eventId,
        action: action,
        userId: userId,
        resourceType: resourceType,
        resourceId: resourceId,
        oldValue: oldValue,
        newValue: newValue,
        ipAddress: ipAddress,
        userAgent: userAgent,
        createdAt: createdAt,
      );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
