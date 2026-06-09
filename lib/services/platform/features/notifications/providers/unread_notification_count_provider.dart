import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_inbox_api.dart';

/// 사이드바/앱바 배지용 미읽음 알림 수. 부가 정보이므로 조회 실패는 조용히 무시한다.
final unreadNotificationCountProvider =
    NotifierProvider<UnreadNotificationCountNotifier, int>(
      UnreadNotificationCountNotifier.new,
    );

class UnreadNotificationCountNotifier extends Notifier<int> {
  @override
  int build() {
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
