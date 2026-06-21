import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi(ref.watch(dioProvider));
});

enum PlatformNotificationCategory { review, community, achievement, system }

extension PlatformNotificationCategoryLabel on PlatformNotificationCategory {
  String get key {
    return switch (this) {
      PlatformNotificationCategory.review => 'review',
      PlatformNotificationCategory.community => 'community',
      PlatformNotificationCategory.achievement => 'achievement',
      PlatformNotificationCategory.system => 'system',
    };
  }

  String get label {
    return switch (this) {
      PlatformNotificationCategory.review => '복습 리마인더',
      PlatformNotificationCategory.community => '커뮤니티 활동',
      PlatformNotificationCategory.achievement => '성취/배지',
      PlatformNotificationCategory.system => '시스템 알림',
    };
  }
}

enum NotificationChannel { push, email, inApp }

extension NotificationChannelLabel on NotificationChannel {
  String get key {
    return switch (this) {
      NotificationChannel.push => 'push',
      NotificationChannel.email => 'email',
      NotificationChannel.inApp => 'inApp',
    };
  }

  String get label {
    return switch (this) {
      NotificationChannel.push => 'Push',
      NotificationChannel.email => 'Email',
      NotificationChannel.inApp => 'InApp',
    };
  }
}

class PlatformNotification {
  const PlatformNotification({
    required this.id,
    required this.title,
    required this.category,
    required this.isRead,
    this.body,
    this.channel,
    this.createdAt,
    this.actionUrl,
  });

  factory PlatformNotification.fromJson(Map<String, dynamic> json) {
    final dataJson = _mapValue(json, 'dataJson') ?? _mapValue(json, 'data');
    final categoryValue =
        _stringValue(json, const [
          'category',
          'notificationType',
          'type',
          'templateCode',
        ]) ??
        '';
    final createdAt = _stringValue(json, const [
      'createdAt',
      'created_at',
      'occurredAt',
    ]);

    return PlatformNotification(
      id: _stringValue(json, const ['id', 'notificationId']) ?? '',
      title:
          _stringValue(json, const ['title', 'subject', 'templateCode']) ??
          '알림',
      body: _stringValue(json, const ['body', 'message', 'content']),
      category: _parseCategory(categoryValue),
      channel: _stringValue(json, const ['channel']),
      isRead: _boolValue(json, const ['isRead', 'read']) ?? false,
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt),
      actionUrl:
          _stringValue(json, const ['actionUrl', 'url', 'route']) ??
          (dataJson == null
              ? null
              : _stringValue(dataJson, const ['actionUrl', 'url', 'route'])),
    );
  }

  final String id;
  final String title;
  final String? body;
  final PlatformNotificationCategory category;
  final String? channel;
  final bool isRead;
  final DateTime? createdAt;
  final String? actionUrl;

  PlatformNotification copyWith({bool? isRead}) {
    return PlatformNotification(
      id: id,
      title: title,
      body: body,
      category: category,
      channel: channel,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      actionUrl: actionUrl,
    );
  }
}

class NotificationPage {
  const NotificationPage({
    required this.notifications,
    required this.unreadCount,
    required this.hasMore,
  });

  final List<PlatformNotification> notifications;
  final int unreadCount;
  final bool hasMore;

  NotificationPage markRead(String id) {
    final next = notifications
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList(growable: false);
    return NotificationPage(
      notifications: next,
      unreadCount: next.where((item) => !item.isRead).length,
      hasMore: hasMore,
    );
  }

  NotificationPage markAllRead() {
    final next = notifications
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
    return NotificationPage(
      notifications: next,
      unreadCount: 0,
      hasMore: hasMore,
    );
  }
}

class NotificationChannelSettings {
  const NotificationChannelSettings({
    required this.push,
    required this.email,
    required this.inApp,
  });

  factory NotificationChannelSettings.fromJson(
    Map<String, dynamic> json, {
    NotificationChannelSettings fallback = NotificationChannelSettings.enabled,
  }) {
    return NotificationChannelSettings(
      push:
          _boolValue(json, const ['pushEnabled', 'push', 'push_enabled']) ??
          fallback.push,
      email:
          _boolValue(json, const ['emailEnabled', 'email', 'email_enabled']) ??
          fallback.email,
      inApp:
          _boolValue(json, const ['inAppEnabled', 'inApp', 'in_app_enabled']) ??
          fallback.inApp,
    );
  }

  static const enabled = NotificationChannelSettings(
    push: true,
    email: true,
    inApp: true,
  );

  final bool push;
  final bool email;
  final bool inApp;

  bool isEnabled(NotificationChannel channel) {
    return switch (channel) {
      NotificationChannel.push => push,
      NotificationChannel.email => email,
      NotificationChannel.inApp => inApp,
    };
  }

  NotificationChannelSettings copyWith({bool? push, bool? email, bool? inApp}) {
    return NotificationChannelSettings(
      push: push ?? this.push,
      email: email ?? this.email,
      inApp: inApp ?? this.inApp,
    );
  }

  NotificationChannelSettings setChannel(
    NotificationChannel channel,
    bool enabled,
  ) {
    return switch (channel) {
      NotificationChannel.push => copyWith(push: enabled),
      NotificationChannel.email => copyWith(email: enabled),
      NotificationChannel.inApp => copyWith(inApp: enabled),
    };
  }

  Map<String, dynamic> toJson() {
    return {'pushEnabled': push, 'emailEnabled': email, 'inAppEnabled': inApp};
  }
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.categories,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });

  factory NotificationPreferences.defaults() {
    return NotificationPreferences(
      categories: Map.unmodifiable({
        for (final category in PlatformNotificationCategory.values)
          category: NotificationChannelSettings.enabled,
      }),
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
    );
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final defaults = NotificationPreferences.defaults();
    final source = _mapValue(json, 'data') ?? json;
    final baseSettings = NotificationChannelSettings.fromJson(
      source,
      fallback: NotificationChannelSettings.enabled,
    );
    final categories = {
      for (final category in PlatformNotificationCategory.values)
        category: baseSettings,
    };

    final categoryMap =
        _mapValue(source, 'categories') ??
        _mapValue(source, 'notificationPrefs') ??
        _mapValue(source, 'notification_prefs');
    if (categoryMap != null) {
      for (final entry in categoryMap.entries) {
        final category = _parseCategory(entry.key);
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          categories[category] = NotificationChannelSettings.fromJson(
            value,
            fallback: categories[category] ?? baseSettings,
          );
        }
      }
    }

    final preferenceList = _listValue(source, 'preferences');
    if (preferenceList != null) {
      for (final item in preferenceList.whereType<Map<String, dynamic>>()) {
        final category = _parseCategory(
          _stringValue(item, const ['category']) ?? '',
        );
        categories[category] = NotificationChannelSettings.fromJson(
          item,
          fallback: categories[category] ?? baseSettings,
        );
      }
    }

    return NotificationPreferences(
      categories: Map.unmodifiable(categories),
      quietHoursStart:
          _stringValue(source, const [
            'quietHoursStart',
            'quietStart',
            'quiet_hours_start',
          ]) ??
          defaults.quietHoursStart,
      quietHoursEnd:
          _stringValue(source, const [
            'quietHoursEnd',
            'quietEnd',
            'quiet_hours_end',
          ]) ??
          defaults.quietHoursEnd,
    );
  }

  final Map<PlatformNotificationCategory, NotificationChannelSettings>
  categories;
  final String quietHoursStart;
  final String quietHoursEnd;

  NotificationChannelSettings channelsFor(
    PlatformNotificationCategory category,
  ) {
    return categories[category] ?? NotificationChannelSettings.enabled;
  }

  NotificationPreferences setChannel({
    required PlatformNotificationCategory category,
    required NotificationChannel channel,
    required bool enabled,
  }) {
    final next =
        Map<PlatformNotificationCategory, NotificationChannelSettings>.from(
          categories,
        );
    next[category] = channelsFor(category).setChannel(channel, enabled);
    return copyWith(categories: Map.unmodifiable(next));
  }

  NotificationPreferences copyWith({
    Map<PlatformNotificationCategory, NotificationChannelSettings>? categories,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferences(
      categories: categories ?? this.categories,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': {
        for (final entry in categories.entries)
          entry.key.key: entry.value.toJson(),
      },
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }
}

class NotificationApi {
  const NotificationApi(this._dio);

  final Dio _dio;

  Future<NotificationPage> listNotifications({
    int page = 0,
    int size = 50,
    PlatformNotificationCategory? category,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/notifications',
      queryParameters: {
        'page': page,
        'size': size,
        if (category != null) 'category': category.key,
      },
    );
    final payload = response.data;
    final items = _extractNotificationList(payload);
    final notifications = items
        .whereType<Map<String, dynamic>>()
        .map(PlatformNotification.fromJson)
        .toList(growable: false);

    final map = payload is Map<String, dynamic> ? payload : null;
    final unreadCount =
        _intValue(map, const ['unreadCount', 'unread_count', 'totalUnread']) ??
        notifications.where((item) => !item.isRead).length;
    final hasMore =
        _boolValue(map, const ['hasMore', 'has_more']) ??
        _inferHasMore(map, page, size, notifications.length);

    return NotificationPage(
      notifications: notifications,
      unreadCount: unreadCount,
      hasMore: hasMore,
    );
  }

  Future<void> markRead(String id) async {
    await _dio.patch<void>('/api/v1/notifications/$id/read');
  }

  Future<NotificationPreferences> getPreferences() async {
    final response = await _dio.get<dynamic>(
      '/api/v1/notifications/preferences',
    );
    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return NotificationPreferences.fromJson(payload);
    }
    return NotificationPreferences.defaults();
  }

  Future<void> updatePreferences(NotificationPreferences preferences) async {
    await _dio.put<void>(
      '/api/v1/notifications/preferences',
      data: preferences.toJson(),
    );
  }
}

List<dynamic> _extractNotificationList(dynamic payload) {
  if (payload is List) return payload;
  if (payload is! Map<String, dynamic>) return const [];
  for (final key in const ['data', 'items', 'content', 'notifications']) {
    final value = payload[key];
    if (value is List) return value;
    if (value is Map<String, dynamic>) {
      final nested = _extractNotificationList(value);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

PlatformNotificationCategory _parseCategory(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('review') ||
      normalized.contains('card') ||
      normalized.contains('reminder')) {
    return PlatformNotificationCategory.review;
  }
  if (normalized.contains('community') ||
      normalized.contains('group') ||
      normalized.contains('deck') ||
      normalized.contains('note.shared')) {
    return PlatformNotificationCategory.community;
  }
  if (normalized.contains('achievement') ||
      normalized.contains('badge') ||
      normalized.contains('level') ||
      normalized.contains('gamification') ||
      normalized.contains('xp')) {
    return PlatformNotificationCategory.achievement;
  }
  return PlatformNotificationCategory.system;
}

bool _inferHasMore(
  Map<String, dynamic>? payload,
  int page,
  int size,
  int itemCount,
) {
  final totalPages = _intValue(payload, const ['totalPages', 'total_pages']);
  if (totalPages != null) return page + 1 < totalPages;
  return itemCount >= size;
}

Map<String, dynamic>? _mapValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<dynamic>? _listValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is List ? value : null;
}

String? _stringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

bool? _boolValue(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
  }
  return null;
}

int? _intValue(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}
