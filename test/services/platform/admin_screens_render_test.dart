import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/platform/features/admin/presentation/screens/admin_screens.dart';

// 관리자 화면(웹 전용) reskin 후 데스크탑/태블릿 렌더 검증.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
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
  const tablet = Size(820, 1100);

  for (final entry in <String, Widget>{
    'AdminDashboardScreen': const AdminDashboardScreen(),
    'AdminTenantScreen': const AdminTenantScreen(),
    'AdminUserScreen': const AdminUserScreen(),
    'AdminAuditLogScreen': const AdminAuditLogScreen(),
    'AdminSystemSettingsScreen': const AdminSystemSettingsScreen(),
    'AdminReportScreen': const AdminReportScreen(),
    'AdminContentScreen': const AdminContentScreen(),
    'AdminGroupScreen': const AdminGroupScreen(),
    'AdminGamificationScreen': const AdminGamificationScreen(),
    'AdminDataRequestScreen': const AdminDataRequestScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 태블릿 렌더', (tester) async {
      await pump(tester, entry.value, tablet);
    });
  }
}
