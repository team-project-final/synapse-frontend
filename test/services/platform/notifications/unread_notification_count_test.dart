import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
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

  test('폴링 주기마다 unreadCount를 다시 조회한다', () {
    fakeAsync((async) {
      final api = _FakeApi(3);
      final container = ProviderContainer(
        overrides: [
          notificationInboxApiProvider.overrideWithValue(api),
          unreadNotificationPollIntervalProvider.overrideWithValue(
            const Duration(seconds: 30),
          ),
        ],
      );

      container.read(unreadNotificationCountProvider);
      async.flushMicrotasks();
      expect(api.callCount, 1); // 최초 로드

      async.elapse(const Duration(seconds: 61));
      expect(api.callCount, 3); // 30초 × 2회 추가
      expect(container.read(unreadNotificationCountProvider), 3);

      // dispose 후에는 타이머가 멈춰야 한다.
      container.dispose();
      async.elapse(const Duration(seconds: 120));
      expect(api.callCount, 3);
    });
  });

  test('폴링 주기를 null로 두면 폴링하지 않는다', () {
    fakeAsync((async) {
      final api = _FakeApi(3);
      final container = ProviderContainer(
        overrides: [
          notificationInboxApiProvider.overrideWithValue(api),
          unreadNotificationPollIntervalProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      container.read(unreadNotificationCountProvider);
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 5));

      expect(api.callCount, 1); // 최초 로드만
    });
  });
}

class _FakeApi extends NotificationInboxApi {
  _FakeApi(this._count, {this.fail = false}) : super(Dio());

  final int _count;
  final bool fail;
  int callCount = 0;

  @override
  Future<int> unreadCount() async {
    callCount++;
    if (fail) throw Exception('boom');
    return _count;
  }
}
