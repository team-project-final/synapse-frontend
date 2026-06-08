import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_tenant.dart';

/// platform-svc AdminTenantResponse(JSON) DTO.
class AdminTenantModel {
  const AdminTenantModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.plan,
    required this.status,
    this.createdAt,
  });

  factory AdminTenantModel.fromJson(Map<String, dynamic> json) {
    return AdminTenantModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      plan: json['plan']?.toString() ?? 'free',
      status: json['status']?.toString() ?? 'unknown',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  final String id;
  final String name;
  final String slug;
  final String plan;
  final String status;
  final DateTime? createdAt;

  AdminTenant toEntity() => AdminTenant(
        id: id,
        name: name,
        slug: slug,
        plan: plan,
        status: status,
        createdAt: createdAt,
      );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
