import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/platform/features/notifications/data/notification_settings_api.dart';
import 'package:synapse_frontend/services/platform/features/notifications/presentation/screens/notification_screens.dart';
import 'package:synapse_frontend/services/platform/features/settings/data/account_api.dart';
import 'package:synapse_frontend/services/platform/features/settings/data/tenant_api.dart';
import 'package:synapse_frontend/services/platform/features/settings/presentation/screens/settings_screens.dart';

import 'settings/account_api_fakes.dart';

// 설정 화면(프로필/보안/알림/테넌트) reskin 후 데스크탑/모바일 렌더 검증.
// 알림 설정은 설정 허브에서도 실연동 화면(NotificationPreferenceScreen)을 재사용한다.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountApiProvider.overrideWithValue(FakeAccountApi()),
          tenantApiProvider.overrideWithValue(FakeTenantApi()),
          notificationSettingsApiProvider.overrideWithValue(
            _FakeNotificationSettingsApi(),
          ),
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
    'ProfileSettingsScreen': const ProfileSettingsScreen(),
    'SecuritySettingsScreen': const SecuritySettingsScreen(),
    'NotificationPreferenceScreen': const NotificationPreferenceScreen(),
    'TenantSettingsScreen': const TenantSettingsScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }
}

class _FakeNotificationSettingsApi extends NotificationSettingsApi {
  _FakeNotificationSettingsApi() : super(Dio());

  @override
  Future<NotificationSettings> get() async {
    return NotificationSettings.fromJson(const {});
  }

  @override
  Future<NotificationSettings> update(NotificationSettings settings) async {
    return settings;
  }
}
