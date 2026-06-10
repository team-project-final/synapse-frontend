import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_inbox_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/providers/unread_notification_count_provider.dart';

void main() {
  test('refresh는 unreadCount API 값으로 state를 갱신한다', () async {
    final container = ProviderContainer(
      overrides: [notificationInboxApiProvider.overrideWithValue(_FakeApi(7))],
    );
    addTearDown(container.dispose);

    await container.read(unreadNotificationCountProvider.notifier).refresh();

    expect(container.read(unreadNotificationCountProvider), 7);
  });

  test('조회 실패 시 0을 유지한다(예외 무시)', () async {
    final container = ProviderContainer(
      overrides: [
        notificationInboxApiProvider.overrideWithValue(_FakeApi(0, fail: true)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(unreadNotificationCountProvider.notifier).refresh();

    expect(container.read(unreadNotificationCountProvider), 0);
  });
}

class _FakeApi extends NotificationInboxApi {
  _FakeApi(this._count, {this.fail = false}) : super(Dio());

  final int _count;
  final bool fail;

  @override
  Future<int> unreadCount() async {
    if (fail) throw Exception('boom');
    return _count;
  }
}
