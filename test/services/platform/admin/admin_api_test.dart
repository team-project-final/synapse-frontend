import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/admin_api.dart';

void main() {
  test('getAnalyticsSummary maps admin summary response', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/analytics/summary');
        return ResponseBody.fromString(
          jsonEncode({
            'generatedAt': '2026-06-21T09:30:00Z',
            'users': {
              'total': 100,
              'active': 90,
              'suspended': 2,
              'deleted': 8,
              'newToday': 5,
              'dau': 30,
              'mau': 80,
              'activitySource': 'audit',
            },
            'tenants': {
              'total': 10,
              'active': 8,
              'suspended': 1,
              'plans': {'free': 6, 'pro': 2},
            },
            'usage': [
              {
                'key': 'subscriptions.active',
                'label': '활성 구독',
                'value': 2,
                'unit': '건',
                'status': 'OK',
                'source': 'billing',
              },
            ],
            'pendingItems': [
              {
                'key': 'reports',
                'label': '신고',
                'count': 3,
                'severity': 'P1',
                'status': 'OPEN',
              },
            ],
            'recentActivities': [
              {
                'id': '11111111-1111-1111-1111-111111111111',
                'action': 'USER_LOGIN',
                'userId': '22222222-2222-2222-2222-222222222222',
                'resourceType': 'USER',
                'resourceId': '22222222-2222-2222-2222-222222222222',
                'createdAt': '2026-06-21T09:20:00Z',
              },
            ],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = AdminApi(dio);

    final summary = await api.getAnalyticsSummary();

    expect(summary.users.dau, 30);
    expect(summary.tenants.plans['pro'], 2);
    expect(summary.usage.single.label, '활성 구독');
    expect(summary.pendingItems.single.count, 3);
    expect(summary.recentActivities.single.action, 'USER_LOGIN');
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
