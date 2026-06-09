import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_settings_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/presentation/screens/notification_screens.dart';

void main() {
  group('NotificationSettings JSON', () {
    test('fromJson은 카테고리 그리드와 quietHours를 매핑한다', () {
      final s = NotificationSettings.fromJson({
        'categories': {
          'reviewReminder': {'push': true, 'email': false, 'inApp': true},
          'communityActivity': {'push': false, 'email': true, 'inApp': false},
          'achievement': {'push': true, 'email': true, 'inApp': true},
          'system': {'push': false, 'email': false, 'inApp': true},
        },
        'quietHours': {'start': '23:30', 'end': '07:15'},
      });

      expect(s.grid[0], [true, false, true]); // reviewReminder
      expect(s.grid[1], [false, true, false]); // communityActivity
      expect(s.grid[3], [false, false, true]); // system
      expect(s.quietStart, '23:30');
      expect(s.quietEnd, '07:15');
    });

    test('누락 시 기본값(false / 22:00~08:00)', () {
      final s = NotificationSettings.fromJson(const {});
      expect(s.grid.length, 4);
      expect(s.grid[0], [false, false, false]);
      expect(s.quietStart, '22:00');
      expect(s.quietEnd, '08:00');
    });

    test('toJson은 카테고리 키·채널 키로 직렬화한다', () {
      const s = NotificationSettings(
        grid: [
          [true, false, true],
          [false, true, false],
          [true, true, true],
          [false, false, true],
        ],
        quietStart: '21:00',
        quietEnd: '06:00',
      );

      final json = s.toJson();
      final categories = json['categories'] as Map;
      expect(categories['reviewReminder'], {
        'push': true,
        'email': false,
        'inApp': true,
      });
      expect(categories['system'], {
        'push': false,
        'email': false,
        'inApp': true,
      });
      expect(json['quietHours'], {'start': '21:00', 'end': '06:00'});
    });
  });

  group('NotificationPreferenceScreen', () {
    Future<void> pump(WidgetTester tester, _FakeSettingsApi api) async {
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [notificationSettingsApiProvider.overrideWithValue(api)],
          child: const MaterialApp(
            home: Scaffold(body: NotificationPreferenceScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('로드된 방해금지 시간을 표시한다', (tester) async {
      final api = _FakeSettingsApi(
        NotificationSettings.fromJson({
          'quietHours': {'start': '23:00', 'end': '05:00'},
        }),
      );
      await pump(tester, api);

      expect(find.text('시작: 23:00'), findsOneWidget);
      expect(find.text('종료: 05:00'), findsOneWidget);
    });

    testWidgets('저장 버튼이 update를 호출하고 안내를 보여준다', (tester) async {
      final api = _FakeSettingsApi(NotificationSettings.fromJson(const {}));
      await pump(tester, api);

      await tester.tap(find.widgetWithText(FilledButton, '저장'));
      await tester.pumpAndSettle();

      expect(api.updateCount, 1);
      expect(find.text('알림 설정이 저장되었습니다.'), findsOneWidget);
    });
  });
}

class _FakeSettingsApi extends NotificationSettingsApi {
  _FakeSettingsApi(this._settings) : super(Dio());

  final NotificationSettings _settings;
  int updateCount = 0;

  @override
  Future<NotificationSettings> get() async => _settings;

  @override
  Future<NotificationSettings> update(NotificationSettings settings) async {
    updateCount++;
    return settings;
  }
}
