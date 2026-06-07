import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_device_api.dart';

void main() {
  test('registerDevice posts lowercase platform and maps device id', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/notifications/devices');
        expect(options.method, 'POST');
        expect(options.data, {'token': 'fcm-token', 'platform': 'web'});
        return ResponseBody.fromString(
          jsonEncode({'id': 'device-1'}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = NotificationDeviceApi(dio);

    final device = await api.registerDevice(
      token: 'fcm-token',
      platform: 'WEB',
    );

    expect(device.id, 'device-1');
  });

  test('deleteDevice sends device id as path parameter', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/notifications/devices/device-1');
        expect(options.method, 'DELETE');
        return ResponseBody.fromString('', 204);
      });
    final api = NotificationDeviceApi(dio);

    await api.deleteDevice('device-1');
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
