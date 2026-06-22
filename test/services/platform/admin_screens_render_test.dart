import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/engagement/providers/engagement_providers.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/admin_api.dart';
import 'package:synapse_frontend/services/platform/features/admin/presentation/screens/admin_screens.dart';

import '../engagement/fake_engagement_api.dart';

// 관리자 화면(웹 전용) reskin 후 데스크탑/태블릿 렌더 검증.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminApiProvider.overrideWithValue(_FakeAdminApi()),
          engagementApiProvider.overrideWithValue(FakeEngagementApi()),
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

class _FakeAdminApi extends AdminApi {
  _FakeAdminApi() : super(Dio());

  @override
  Future<AdminAnalyticsSummary> getAnalyticsSummary() async {
    return const AdminAnalyticsSummary(
      users: AdminUsersSummary(
        total: 100,
        active: 90,
        suspended: 2,
        deleted: 8,
        newToday: 5,
        dau: 30,
        mau: 80,
        activitySource: 'audit',
      ),
      tenants: AdminTenantsSummary(
        total: 10,
        active: 8,
        suspended: 1,
        plans: {'free': 6, 'pro': 2},
      ),
      usage: [
        AdminUsageItem(
          key: 'subscriptions.active',
          label: '활성 구독',
          value: 2,
          unit: '건',
          status: 'OK',
          source: 'billing',
        ),
      ],
      pendingItems: [
        AdminPendingItem(
          key: 'reports',
          label: '신고',
          count: 3,
          severity: 'P1',
          status: 'OPEN',
        ),
      ],
      recentActivities: [
        AdminRecentActivity(
          action: 'USER_LOGIN',
          userId: 'user-1',
          resourceType: 'USER',
          resourceId: 'user-1',
          createdAt: null,
        ),
      ],
    );
  }
}
