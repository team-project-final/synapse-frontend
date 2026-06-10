import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';

final notificationInboxApiProvider = Provider<NotificationInboxApi>((ref) {
  return NotificationInboxApi(ref.watch(dioProvider));
});

/// 알림 화면 분류(탭·아이콘 공용).
enum NotificationCategory { review, community, achievement, other }

/// notificationType(UPPER_SNAKE 자유 문자열)을 화면 분류로 매핑한다.
///
/// 백엔드에 중앙 enum이나 type→category 매핑이 없어 키워드 휴리스틱으로 분류하며,
/// 미지 타입은 [NotificationCategory.other]. 실제 확정 값 예: AI_CARDS_READY(review),
/// REPORT_RESOLVED·CONTENT_REMOVED(community), USER_WELCOME(other). 중앙 taxonomy가
/// 정해지면 이 함수만 갱신하면 된다.
NotificationCategory notificationCategoryOf(String type) {
  final upper = type.toUpperCase();
  bool has(List<String> keywords) => keywords.any(upper.contains);
  if (has(const ['CARD', 'REVIEW', 'DECK', 'STUDY', 'SRS'])) {
    return NotificationCategory.review;
  }
  if (has(const [
    'REPORT',
    'CONTENT',
    'GROUP',
    'COMMUNITY',
    'SHARE',
    'INVITE',
    'MODERAT',
  ])) {
    return NotificationCategory.community;
  }
  if (has(const ['BADGE', 'LEVEL', 'XP', 'STREAK', 'ACHIEVE'])) {
    return NotificationCategory.achievement;
  }
  return NotificationCategory.other;
}

/// 알림 클릭 시 이동할 화면. 백엔드 알림에 딥링크 페이로드가 없어
/// 분류 기반으로 대표 화면에 연결하며, 시스템/미지 타입은 이동하지 않는다(null).
String? notificationRouteOf(String type) {
  return switch (notificationCategoryOf(type)) {
    NotificationCategory.review => AppRoutes.review,
    NotificationCategory.community => AppRoutes.communityGroups,
    NotificationCategory.achievement => AppRoutes.gamificationProfile,
    NotificationCategory.other => null,
  };
}

/// 알림 인박스 단건. platform-svc `NotificationItemResponse`를 화면용 엔티티로
/// 변환한 형태(아이콘·색·상대시간 등 표현은 UI 계층에서 type/createdAt으로 파생).
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.read,
    required this.createdAt,
    this.title,
    this.body,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      title: json['title'] as String?,
      body: json['body'] as String?,
    );
  }

  final String id;
  final String type;
  final bool read;
  final DateTime createdAt;
  final String? title;
  final String? body;

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
      title: title,
      body: body,
    );
  }
}

class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.page,
    required this.totalElements,
    required this.totalPages,
  });

  final List<NotificationItem> items;
  final int page;
  final int totalElements;
  final int totalPages;
}

/// platform-svc `/api/v1/notifications` 인박스 API 클라이언트.
class NotificationInboxApi {
  const NotificationInboxApi(this._dio);

  final Dio _dio;

  Future<NotificationPage> list({int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/notifications',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data ?? const <String, dynamic>{};
    final items = (data['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .toList();
    return NotificationPage(
      items: items,
      page: (data['page'] as num?)?.toInt() ?? 0,
      totalElements: (data['totalElements'] as num?)?.toInt() ?? items.length,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<int> unreadCount() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/notifications/unread-count',
    );
    return (response.data?['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String id) async {
    await _dio.put<void>('/api/v1/notifications/$id/read');
  }

  Future<int> markAllRead() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/notifications/read-all',
    );
    return (response.data?['updatedCount'] as num?)?.toInt() ?? 0;
  }
}
