import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_api.dart';

final notificationCenterProvider =
    AsyncNotifierProvider<NotificationCenterNotifier, NotificationPage>(
      NotificationCenterNotifier.new,
    );

final notificationPreferencesProvider =
    AsyncNotifierProvider<
      NotificationPreferencesNotifier,
      NotificationPreferences
    >(NotificationPreferencesNotifier.new);

class NotificationCenterNotifier extends AsyncNotifier<NotificationPage> {
  @override
  Future<NotificationPage> build() {
    return ref.watch(notificationApiProvider).listNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationApiProvider).listNotifications(),
    );
  }

  Future<void> markRead(String id) async {
    final current = _dataOrNull(state);
    if (current == null || id.isEmpty) return;

    state = AsyncData(current.markRead(id));
    try {
      await ref.read(notificationApiProvider).markRead(id);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markAllRead() async {
    final current = _dataOrNull(state);
    if (current == null) return;

    final unread = current.notifications
        .where((item) => !item.isRead && item.id.isNotEmpty)
        .toList(growable: false);
    if (unread.isEmpty) return;

    state = AsyncData(current.markAllRead());
    try {
      final api = ref.read(notificationApiProvider);
      await Future.wait(unread.map((item) => api.markRead(item.id)));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

class NotificationPreferencesNotifier
    extends AsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() {
    return ref.watch(notificationApiProvider).getPreferences();
  }

  Future<void> updateChannel({
    required PlatformNotificationCategory category,
    required NotificationChannel channel,
    required bool enabled,
  }) async {
    final current = _dataOrNull(state);
    if (current == null) return;

    final next = current.setChannel(
      category: category,
      channel: channel,
      enabled: enabled,
    );
    await _save(next);
  }

  Future<void> setQuietHours({
    required String start,
    required String end,
  }) async {
    final current = _dataOrNull(state);
    if (current == null) return;
    await _save(current.copyWith(quietHoursStart: start, quietHoursEnd: end));
  }

  Future<void> _save(NotificationPreferences next) async {
    final previous = _dataOrNull(state);
    state = AsyncData(next);
    try {
      await ref.read(notificationApiProvider).updatePreferences(next);
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(previous);
      }
      state = AsyncError(error, stackTrace);
    }
  }
}

T? _dataOrNull<T>(AsyncValue<T> value) {
  return value.when(
    data: (data) => data,
    loading: () => null,
    error: (_, _) => null,
  );
}
