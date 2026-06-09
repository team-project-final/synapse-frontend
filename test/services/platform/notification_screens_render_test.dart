import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_inbox_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_settings_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/presentation/screens/notification_screens.dart';

// 알림 센터/알림 설정 화면 reskin 후 데스크탑/모바일 렌더 검증.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationInboxApiProvider.overrideWithValue(_StubInboxApi()),
          notificationSettingsApiProvider.overrideWithValue(_StubSettingsApi()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  const desktop = Size(1440, 900);
  const mobile = Size(390, 844);

  for (final entry in <String, Widget>{
    'NotificationCenterScreen': const NotificationCenterScreen(),
    'NotificationPreferenceScreen': const NotificationPreferenceScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }
}

class _StubInboxApi extends NotificationInboxApi {
  _StubInboxApi() : super(Dio());

  @override
  Future<NotificationPage> list({int page = 0, int size = 20}) async =>
      const NotificationPage(
        items: [],
        page: 0,
        totalElements: 0,
        totalPages: 1,
      );
}

class _StubSettingsApi extends NotificationSettingsApi {
  _StubSettingsApi() : super(Dio());

  @override
  Future<NotificationSettings> get() async => NotificationSettings.fromJson(
    const {},
  );
}
