import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_inbox_api.dart';

/// 미읽음 뱃지 폴링 주기. 기본 null(폴링 꺼짐)이고 앱 부트스트랩(main.dart)에서만
/// 30초로 켠다 — 위젯 테스트가 타이머 정리를 신경 쓰지 않아도 되게 하기 위함.
final unreadNotificationPollIntervalProvider = Provider<Duration?>((_) => null);

/// 사이드바/앱바 배지용 미읽음 알림 수. 부가 정보이므로 조회 실패는 조용히 무시한다.
final unreadNotificationCountProvider =
    NotifierProvider<UnreadNotificationCountNotifier, int>(
      UnreadNotificationCountNotifier.new,
    );

class UnreadNotificationCountNotifier extends Notifier<int> {
  @override
  int build() {
    final interval = ref.watch(unreadNotificationPollIntervalProvider);
    if (interval != null) {
      final timer = Timer.periodic(interval, (_) => refresh());
      ref.onDispose(timer.cancel);
    }
    Future<void>.microtask(refresh);
    return 0;
  }

  Future<void> refresh() async {
    try {
      state = await ref.read(notificationInboxApiProvider).unreadCount();
    } catch (_) {
      // 배지는 부가 정보 — 실패해도 화면 흐름에 영향 주지 않는다.
    }
  }
}
