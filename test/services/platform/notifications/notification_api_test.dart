import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_api.dart';

void main() {
  test('listNotifications maps inbox data envelope', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/notifications');
        expect(options.method, 'GET');
        expect(options.queryParameters['page'], 0);
        expect(options.queryParameters['size'], 50);
        return ResponseBody.fromString(
          jsonEncode({
            'data': [
              {
                'id': 'noti-1',
                'category': 'review',
                'title': '오늘 복습할 카드 25장',
                'body': '마감 전 복습을 시작하세요.',
                'isRead': false,
                'createdAt': '2026-06-21T08:00:00Z',
                'dataJson': {'route': '/review'},
              },
            ],
            'unreadCount': 1,
            'hasMore': false,
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    final api = NotificationApi(dio);

    final page = await api.listNotifications();

    expect(page.unreadCount, 1);
    expect(page.hasMore, isFalse);
    expect(page.notifications.single.id, 'noti-1');
    expect(
      page.notifications.single.category,
      PlatformNotificationCategory.review,
    );
    expect(page.notifications.single.actionUrl, '/review');
  });

  test('markRead sends patch request to read endpoint', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/notifications/noti-1/read');
        expect(options.method, 'PATCH');
        return ResponseBody.fromString('', 204);
      });
    final api = NotificationApi(dio);

    await api.markRead('noti-1');
  });

  test('notification preferences round-trip category channels', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        requests.add(options);
        if (options.method == 'GET') {
          expect(options.path, '/api/v1/notifications/preferences');
          return ResponseBody.fromString(
            jsonEncode({
              'data': {
                'categories': {
                  'review': {
                    'pushEnabled': true,
                    'emailEnabled': false,
                    'inAppEnabled': true,
                  },
                },
                'quietHoursStart': '23:00',
                'quietHoursEnd': '07:00',
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        expect(options.path, '/api/v1/notifications/preferences');
        expect(options.method, 'PUT');
        return ResponseBody.fromString('', 204);
      });
    final api = NotificationApi(dio);

    final preferences = await api.getPreferences();
    final updated = preferences.setChannel(
      category: PlatformNotificationCategory.review,
      channel: NotificationChannel.email,
      enabled: true,
    );
    await api.updatePreferences(updated);

    expect(preferences.quietHoursStart, '23:00');
    expect(
      preferences
          .channelsFor(PlatformNotificationCategory.review)
          .isEnabled(NotificationChannel.email),
      isFalse,
    );
    final requestBody = requests.last.data as Map<String, dynamic>;
    final categories = requestBody['categories'] as Map<String, dynamic>;
    final review = categories['review'] as Map<String, dynamic>;
    expect(review['emailEnabled'], isTrue);
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
