import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final notificationSettingsApiProvider = Provider<NotificationSettingsApi>((ref) {
  return NotificationSettingsApi(ref.watch(dioProvider));
});

/// platform-svc 알림 설정. 카테고리(행) × 채널(열) on/off 그리드 + 방해금지 시간.
/// 행 순서는 [categoryKeys], 열 순서는 [channelKeys]를 따른다(화면 그리드와 1:1).
class NotificationSettings {
  const NotificationSettings({
    required this.grid,
    required this.quietStart,
    required this.quietEnd,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'] as Map? ?? const {};
    final grid = categoryKeys.map((cat) {
      final channels = categories[cat] as Map? ?? const {};
      return channelKeys.map((ch) => channels[ch] as bool? ?? false).toList();
    }).toList();
    final quiet = json['quietHours'] as Map? ?? const {};
    return NotificationSettings(
      grid: grid,
      quietStart: quiet['start'] as String? ?? '22:00',
      quietEnd: quiet['end'] as String? ?? '08:00',
    );
  }

  static const categoryKeys = [
    'reviewReminder',
    'communityActivity',
    'achievement',
    'system',
  ];
  static const channelKeys = ['push', 'email', 'inApp'];

  final List<List<bool>> grid;
  final String quietStart; // "HH:mm"
  final String quietEnd;

  Map<String, dynamic> toJson() {
    final categories = <String, dynamic>{};
    for (var i = 0; i < categoryKeys.length; i++) {
      final row = i < grid.length ? grid[i] : const [false, false, false];
      categories[categoryKeys[i]] = {
        for (var j = 0; j < channelKeys.length; j++)
          channelKeys[j]: j < row.length && row[j],
      };
    }
    return {
      'categories': categories,
      'quietHours': {'start': quietStart, 'end': quietEnd},
    };
  }
}

/// platform-svc `/api/v1/notifications/settings` 클라이언트.
class NotificationSettingsApi {
  const NotificationSettingsApi(this._dio);

  final Dio _dio;

  Future<NotificationSettings> get() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/notifications/settings',
    );
    return NotificationSettings.fromJson(response.data ?? const {});
  }

  Future<NotificationSettings> update(NotificationSettings settings) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/notifications/settings',
      data: settings.toJson(),
    );
    return NotificationSettings.fromJson(response.data ?? const {});
  }
}
