import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_analytics_summary.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_audit_log.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_settings.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_tenant.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_user.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/get_admin_analytics_summary_usecase.dart';
import 'package:synapse_frontend/services/platform/features/admin/presentation/screens/admin_screens.dart';
import 'package:synapse_frontend/services/platform/features/admin/providers/admin_providers.dart';

void main() {
  final summary = AdminAnalyticsSummary(
    generatedAt: DateTime.parse('2026-06-10T12:00:00Z'),
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
        id: '33333333-3333-3333-3333-333333333333',
        action: 'USER_REGISTERED',
        userId: '11111111-1111-1111-1111-111111111111',
        resourceType: 'USER',
        resourceId: '11111111-1111-1111-1111-111111111111',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  );

  Future<void> pumpDashboard(
    WidgetTester tester,
    _FakeAdminRepository repository,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAdminAnalyticsSummaryUseCaseProvider.overrideWithValue(
            GetAdminAnalyticsSummaryUseCase(repository),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AdminDashboardScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders KPI, usage, pending, recent activity from summary', (
    tester,
  ) async {
    await pumpDashboard(tester, _FakeAdminRepository(summary: summary));

    // KPI — DAU/MAU가 mock이 아닌 응답 값으로 표시된다.
    expect(find.text('1,200'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('340'), findsOneWidget);
    expect(find.text('980'), findsOneWidget);

    // Usage — OK는 값, NOT_CONNECTED는 미연동 배지.
    expect(find.text('오늘 발송 알림'), findsOneWidget);
    expect(find.text('152'), findsOneWidget);
    expect(find.text('AI 토큰'), findsOneWidget);
    expect(find.text('미연동'), findsOneWidget);

    // Pending — NOT_IMPLEMENTED는 준비 중 배지.
    expect(find.text('GDPR 요청'), findsOneWidget);
    expect(find.text('준비 중'), findsOneWidget);

    // Recent activity — action · resourceType · 상대시간.
    expect(find.text('USER_REGISTERED · USER · 5분 전'), findsOneWidget);
  });

  testWidgets('shows error state with retry and recovers', (tester) async {
    final repository = _FakeAdminRepository(summary: summary, failOnce: true);
    await pumpDashboard(tester, repository);

    expect(find.text('대시보드 데이터를 불러오지 못했습니다.'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('1,200'), findsOneWidget);
  });
}

class _FakeAdminRepository implements AdminRepository {
  _FakeAdminRepository({required this.summary, this.failOnce = false});

  final AdminAnalyticsSummary summary;
  bool failOnce;

  @override
  Future<AdminAnalyticsSummary> getAnalyticsSummary() async {
    if (failOnce) {
      failOnce = false;
      throw Exception('network');
    }
    return summary;
  }

  @override
  Future<AdminPage<AdminUser>> listUsers({
    String? query,
    String? status,
    int page = 0,
    int size = 20,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> changeUserStatus(String id, String status) =>
      throw UnimplementedError();

  @override
  Future<void> deleteUser(String id) => throw UnimplementedError();

  @override
  Future<AdminPage<AdminTenant>> listTenants({int page = 0, int size = 20}) =>
      throw UnimplementedError();

  @override
  Future<void> changeTenantStatus(String id, String status) =>
      throw UnimplementedError();

  @override
  Future<AdminPage<AdminAuditLog>> listAuditLogs({
    String? action,
    String? userId,
    int page = 0,
    int size = 20,
  }) =>
      throw UnimplementedError();

  @override
  Future<AdminSettings> getSettings() => throw UnimplementedError();

  @override
  Future<AdminSettings> updateSettings(AdminSettingsUpdate update) =>
      throw UnimplementedError();
}
