import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final tenantApiProvider = Provider<TenantApi>((ref) {
  return TenantApi(ref.watch(dioProvider));
});

final currentTenantProvider = FutureProvider.autoDispose<CurrentTenant>((ref) {
  return ref.watch(tenantApiProvider).getCurrentTenant();
});

class CurrentTenant {
  const CurrentTenant({
    required this.id,
    required this.name,
    required this.plan,
    required this.status,
    this.myRole,
  });

  factory CurrentTenant.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Invalid tenant response.');
    }
    return CurrentTenant(
      id: id,
      name: (json['name'] as String?) ?? 'Synapse',
      plan: (json['plan'] as String?) ?? 'FREE',
      status: (json['status'] as String?) ?? 'UNKNOWN',
      myRole: json['myRole'] as String?,
    );
  }

  final String id;
  final String name;
  final String plan;
  final String status;
  final String? myRole;
}

class TenantApi {
  const TenantApi(this._dio);

  final Dio _dio;

  Future<CurrentTenant> getCurrentTenant() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/tenants/me');
    final data = response.data ?? const <String, dynamic>{};
    return CurrentTenant.fromJson(data);
  }
}
