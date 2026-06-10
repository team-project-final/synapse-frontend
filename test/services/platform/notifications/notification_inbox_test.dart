import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_inbox_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/presentation/screens/notification_screens.dart';

void main() {
  group('NotificationItem.fromJson', () {
    test('필드를 매핑하고 createdAt을 파싱한다', () {
      final item = NotificationItem.fromJson({
        'id': 'n1',
        'type': 'achievement',
        'title': '레벨업',
        'body': '축하합니다',
        'read': false,
        'createdAt': '2026-06-09T10:00:00Z',
      });

      expect(item.id, 'n1');
      expect(item.type, 'achievement');
      expect(item.title, '레벨업');
      expect(item.read, isFalse);
      expect(item.createdAt.isAfter(DateTime(2026)), isTrue);
    });

    test('누락 필드는 안전한 기본값', () {
      final item = NotificationItem.fromJson({'id': 'n2'});
      expect(item.type, '');
      expect(item.read, isFalse);
      expect(item.title, isNull);
    });

    test('copyWith(read)만 변경한다', () {
      final item = NotificationItem.fromJson({'id': 'n3', 'read': false});
      expect(item.copyWith(read: true).read, isTrue);
      expect(item.copyWith(read: true).id, 'n3');
    });
  });

  group('notificationCategoryOf', () {
    test('카드/복습 키워드 → review', () {
      expect(
        notificationCategoryOf('AI_CARDS_READY'),
        NotificationCategory.review,
      );
      expect(notificationCategoryOf('REVIEW_DUE'), NotificationCategory.review);
    });

    test('신고/콘텐츠/그룹 → community', () {
      expect(
        notificationCategoryOf('REPORT_RESOLVED'),
        NotificationCategory.community,
      );
      expect(
        notificationCategoryOf('CONTENT_REMOVED'),
        NotificationCategory.community,
      );
      expect(
        notificationCategoryOf('GROUP_INVITE'),
        NotificationCategory.community,
      );
    });

    test('배지/레벨 → achievement', () {
      expect(
        notificationCategoryOf('BADGE_EARNED'),
        NotificationCategory.achievement,
      );
      expect(
        notificationCategoryOf('LEVEL_UP'),
        NotificationCategory.achievement,
      );
    });

    test('미지·환영 → other', () {
      expect(notificationCategoryOf('USER_WELCOME'), NotificationCategory.other);
      expect(notificationCategoryOf(''), NotificationCategory.other);
    });
  });

  group('NotificationCenterScreen', () {
    NotificationItem item(String id, {required bool read, String? title}) {
      return NotificationItem(
        id: id,
        type: 'system',
        read: read,
        createdAt: DateTime.now(),
        title: title ?? id,
      );
    }

    Future<void> pump(WidgetTester tester, _FakeInboxApi api) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [notificationInboxApiProvider.overrideWithValue(api)],
          child: const MaterialApp(
            home: Scaffold(body: NotificationCenterScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('로드된 알림을 표시한다', (tester) async {
      await pump(
        tester,
        _FakeInboxApi(items: [item('읽지 않은 알림', read: false)]),
      );
      expect(find.text('읽지 않은 알림'), findsOneWidget);
      expect(find.text('오늘'), findsWidgets);
    });

    testWidgets('알림이 없으면 빈 상태를 보여준다', (tester) async {
      await pump(tester, _FakeInboxApi(items: const []));
      expect(find.text('알림이 없습니다.'), findsWidgets);
    });

    testWidgets('로드 실패 시 에러와 재시도를 보여준다', (tester) async {
      await pump(tester, _FakeInboxApi(throwOnList: true));
      expect(find.text('알림을 불러오지 못했습니다.'), findsWidgets);
      expect(find.text('다시 시도'), findsWidgets);
    });

    testWidgets('모두 읽음 버튼이 markAllRead를 호출한다', (tester) async {
      final api = _FakeInboxApi(items: [item('a', read: false)]);
      await pump(tester, api);

      await tester.tap(find.widgetWithText(TextButton, '모두 읽음'));
      await tester.pumpAndSettle();

      expect(api.markAllReadCount, 1);
    });

    testWidgets('미읽음 항목을 탭하면 markRead를 호출한다', (tester) async {
      final api = _FakeInboxApi(items: [item('탭 대상', read: false)]);
      await pump(tester, api);

      await tester.tap(find.text('탭 대상'));
      await tester.pumpAndSettle();

      expect(api.readIds, ['탭 대상']);
    });
  });
}

class _FakeInboxApi extends NotificationInboxApi {
  _FakeInboxApi({this.items = const [], this.throwOnList = false})
    : super(Dio());

  final List<NotificationItem> items;
  final bool throwOnList;
  int markAllReadCount = 0;
  final List<String> readIds = [];

  @override
  Future<NotificationPage> list({int page = 0, int size = 20}) async {
    if (throwOnList) throw Exception('boom');
    return NotificationPage(
      items: items,
      page: 0,
      totalElements: items.length,
      totalPages: 1,
    );
  }

  @override
  Future<void> markRead(String id) async {
    readIds.add(id);
  }

  @override
  Future<int> markAllRead() async {
    markAllReadCount++;
    return items.where((i) => !i.read).length;
  }

  @override
  Future<int> unreadCount() async => items.where((i) => !i.read).length;
}
