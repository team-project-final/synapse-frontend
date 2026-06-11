import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_analytics_summary.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_audit_log.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_data_request.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_settings.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_tenant.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_user.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/change_tenant_status_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/change_user_status_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/admin_data_request_usecases.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/admin_settings_usecases.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/delete_admin_user_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/get_admin_analytics_summary_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/list_admin_tenants_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/list_admin_users_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/list_audit_logs_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/presentation/screens/admin_screens.dart';
import 'package:synapse_frontend/services/platform/features/admin/providers/admin_providers.dart';

// 관리자 화면(웹 전용) reskin 후 데스크탑/태블릿 렌더 검증.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listAdminUsersUseCaseProvider
              .overrideWithValue(ListAdminUsersUseCase(_FakeAdminRepository())),
          changeUserStatusUseCaseProvider.overrideWithValue(
              ChangeUserStatusUseCase(_FakeAdminRepository())),
          deleteAdminUserUseCaseProvider.overrideWithValue(
              DeleteAdminUserUseCase(_FakeAdminRepository())),
          listAdminTenantsUseCaseProvider.overrideWithValue(
              ListAdminTenantsUseCase(_FakeAdminRepository())),
          changeTenantStatusUseCaseProvider.overrideWithValue(
              ChangeTenantStatusUseCase(_FakeAdminRepository())),
          listAuditLogsUseCaseProvider
              .overrideWithValue(ListAuditLogsUseCase(_FakeAdminRepository())),
          getAdminAnalyticsSummaryUseCaseProvider.overrideWithValue(
              GetAdminAnalyticsSummaryUseCase(_FakeAdminRepository())),
          getAdminSettingsUseCaseProvider.overrideWithValue(
              GetAdminSettingsUseCase(_FakeAdminRepository())),
          updateAdminSettingsUseCaseProvider.overrideWithValue(
              UpdateAdminSettingsUseCase(_FakeAdminRepository())),
          listAdminDataRequestsUseCaseProvider.overrideWithValue(
              ListAdminDataRequestsUseCase(_FakeAdminRepository())),
          createAdminDataRequestUseCaseProvider.overrideWithValue(
              CreateAdminDataRequestUseCase(_FakeAdminRepository())),
          applyAdminDataRequestActionUseCaseProvider.overrideWithValue(
              ApplyAdminDataRequestActionUseCase(_FakeAdminRepository())),
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

class _FakeAdminRepository implements AdminRepository {
  @override
  Future<AdminPage<AdminUser>> listUsers({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    return AdminPage<AdminUser>(
      content: [
        AdminUser(
          id: '11111111-1111-1111-1111-111111111111',
          email: 'admin@synapse.io',
          displayName: '관리자',
          status: 'active',
          createdAt: DateTime.utc(2026),
        ),
        AdminUser(
          id: '22222222-2222-2222-2222-222222222222',
          email: 'banned@test.com',
          displayName: '정지유저',
          status: 'suspended',
          createdAt: DateTime.utc(2026),
        ),
      ],
      page: page,
      size: size,
      totalElements: 2,
      totalPages: 1,
    );
  }

  @override
  Future<void> changeUserStatus(String id, String status) async {}

  @override
  Future<void> deleteUser(String id) async {}

  @override
  Future<AdminPage<AdminTenant>> listTenants({int page = 0, int size = 20}) async {
    return AdminPage<AdminTenant>(
      content: [
        AdminTenant(
          id: '33333333-3333-3333-3333-333333333333',
          name: '스터디그룹A',
          slug: 'study-a',
          plan: 'pro',
          status: 'active',
          createdAt: DateTime.utc(2026),
        ),
      ],
      page: page,
      size: size,
      totalElements: 1,
      totalPages: 1,
    );
  }

  @override
  Future<void> changeTenantStatus(String id, String status) async {}

  @override
  Future<AdminPage<AdminAuditLog>> listAuditLogs({
    String? action,
    String? userId,
    int page = 0,
    int size = 20,
  }) async {
    return AdminPage<AdminAuditLog>(
      content: [
        AdminAuditLog(
          id: '44444444-4444-4444-4444-444444444444',
          eventId: '55555555-5555-5555-5555-555555555555',
          action: 'USER_REGISTERED',
          userId: '11111111-1111-1111-1111-111111111111',
          resourceType: 'USER',
          resourceId: '11111111-1111-1111-1111-111111111111',
          oldValue: '',
          newValue: '',
          ipAddress: '127.0.0.1',
          userAgent: 'test',
          createdAt: DateTime.utc(2026),
        ),
      ],
      page: page,
      size: size,
      totalElements: 1,
      totalPages: 1,
    );
  }

  @override
  Future<AdminAnalyticsSummary> getAnalyticsSummary() async {
    return AdminAnalyticsSummary(
      generatedAt: DateTime.utc(2026, 6, 10),
      users: const AdminUsersSummary(
        total: 1200,
        active: 1100,
        suspended: 50,
        deleted: 50,
        newToday: 12,
        dau: 340,
        mau: 980,
        activitySource: 'USERS_LAST_LOGIN_AT',
      ),
      tenants: const AdminTenantsSummary(
        total: 80,
        active: 75,
        suspended: 5,
        plans: {'free': 60, 'pro': 20},
      ),
      usage: const [
        AdminUsageItem(
          key: 'notifications.sent.today',
          label: '오늘 발송 알림',
          value: 152,
          unit: 'count',
          status: AdminMetricStatus.ok,
          source: 'notifications',
        ),
        AdminUsageItem(
          key: 'ai.tokens.monthly',
          label: 'AI 토큰',
          value: null,
          unit: 'tokens',
          status: AdminMetricStatus.notConnected,
          source: 'learning-ai',
        ),
      ],
      pendingItems: const [
        AdminPendingItem(
          key: 'data-requests',
          label: 'GDPR 요청',
          count: null,
          severity: 'INFO',
          status: AdminMetricStatus.notImplemented,
        ),
      ],
      recentActivities: [
        AdminRecentActivity(
          id: '44444444-4444-4444-4444-444444444444',
          action: 'USER_REGISTERED',
          userId: '11111111-1111-1111-1111-111111111111',
          resourceType: 'USER',
          resourceId: '11111111-1111-1111-1111-111111111111',
          createdAt: DateTime.utc(2026, 6, 10),
        ),
      ],
    );
  }

  @override
  Future<AdminSettings> getSettings() async {
    return AdminSettings(
      planQuotas: const [
        AdminPlanQuota(
          planCode: 'free',
          displayName: 'Free',
          maxNotes: 100,
          maxCards: 1000,
          maxStorageBytes: 1073741824,
          maxAiTokensMonthly: 1000,
          maxAiCardGenerationsMonthly: 20,
          maxUsersPerTenant: 5,
        ),
        AdminPlanQuota(planCode: 'enterprise', displayName: 'Enterprise'),
      ],
      featureFlags: const [
        AdminFeatureFlag(key: 'ai.card.generation', label: 'AI 카드 생성', enabled: true),
      ],
      rateLimitPerMinute: 100,
      updatedAt: DateTime.utc(2026, 6, 10),
    );
  }

  @override
  Future<AdminSettings> updateSettings(AdminSettingsUpdate update) async {
    return getSettings();
  }

  @override
  Future<AdminPage<AdminDataRequest>> listDataRequests({
    AdminDataRequestStatus? status,
    String? query,
    int page = 0,
    int size = 20,
  }) async {
    return AdminPage<AdminDataRequest>(
      content: [
        AdminDataRequest(
          id: '55555555-5555-5555-5555-555555555555',
          userId: '11111111-1111-1111-1111-111111111111',
          userEmail: 'user@example.com',
          userDisplayName: '사용자',
          type: AdminDataRequestType.dataAccess,
          typeLabel: '데이터 열람',
          status: AdminDataRequestStatus.pending,
          statusLabel: '대기',
          receivedAt: DateTime.utc(2026, 6, 10),
          dueAt: DateTime.utc(2026, 7, 10),
          daysRemaining: 29,
          executionLogs: const ['2026-06-10 접수'],
        ),
      ],
      page: page,
      size: size,
      totalElements: 1,
      totalPages: 1,
    );
  }

  @override
  Future<AdminDataRequest> createDataRequest({
    required String userId,
    required AdminDataRequestType type,
    String? reason,
  }) async {
    return (await listDataRequests()).content.single;
  }

  @override
  Future<AdminDataRequest> applyDataRequestAction({
    required String id,
    required AdminDataRequestAction action,
    String? reason,
  }) async {
    return (await listDataRequests()).content.single;
  }
}
