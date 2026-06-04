import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final notificationDeviceApiProvider = Provider<NotificationDeviceApi>((ref) {
  return NotificationDeviceApi(ref.watch(dioProvider));
});

class NotificationDevice {
  const NotificationDevice({required this.id});

  final String id;
}

class NotificationDeviceApi {
  const NotificationDeviceApi(this._dio);

  final Dio _dio;

  Future<NotificationDevice> registerDevice({
    required String token,
    required String platform,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/notifications/devices',
      data: {'token': token, 'platform': platform.toLowerCase()},
    );
    final data = response.data ?? const <String, dynamic>{};
    return NotificationDevice(id: data['id'] as String);
  }

  Future<void> deleteDevice(String id) async {
    await _dio.delete<void>('/api/v1/notifications/devices/$id');
  }
}
