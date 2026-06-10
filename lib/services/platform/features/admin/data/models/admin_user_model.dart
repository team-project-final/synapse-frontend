import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_user.dart';

/// platform-svc AdminUserResponse(JSON) DTO.
class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.status,
    this.createdAt,
    this.suspendedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      createdAt: _parseDate(json['createdAt']),
      suspendedAt: _parseDate(json['suspendedAt']),
    );
  }

  final String id;
  final String email;
  final String displayName;
  final String status;
  final DateTime? createdAt;
  final DateTime? suspendedAt;

  AdminUser toEntity() => AdminUser(
        id: id,
        email: email,
        displayName: displayName,
        status: status,
        createdAt: createdAt,
        suspendedAt: suspendedAt,
      );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
