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
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/admin_settings_usecases.dart';
import 'package:synapse_frontend/services/platform/features/admin/presentation/screens/admin_screens.dart';
import 'package:synapse_frontend/services/platform/features/admin/providers/admin_providers.dart';

void main() {
  final settings = AdminSettings(
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
      AdminFeatureFlag(
        key: 'ai.card.generation',
        label: 'AI 카드 생성',
        enabled: true,
      ),
      AdminFeatureFlag(
        key: 'social.login.github',
        label: 'GitHub 로그인',
        enabled: false,
      ),
    ],
    rateLimitPerMinute: 100,
    updatedAt: DateTime.utc(2026, 6, 10),
  );

  Future<_FakeAdminRepository> pumpScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeAdminRepository(settings);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAdminSettingsUseCaseProvider.overrideWithValue(
            GetAdminSettingsUseCase(repository),
          ),
          updateAdminSettingsUseCaseProvider.overrideWithValue(
            UpdateAdminSettingsUseCase(repository),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AdminSystemSettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('플랜 쿼터를 조회 전용으로 표시한다(null은 무제한, 스토리지 GB)', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Free'), findsOneWidget);
    expect(find.text('1 GB'), findsOneWidget);
    expect(find.text('Enterprise'), findsOneWidget);
    expect(find.text('무제한'), findsWidgets);
  });

  testWidgets('플래그 토글 후 저장하면 변경된 플래그와 레이트리밋을 PUT한다', (tester) async {
    final repository = await pumpScreen(tester);

    await tester.tap(find.text('피처 플래그'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('flag-social.login.github')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('admin-settings-save')));
    await tester.pumpAndSettle();

    final update = repository.lastUpdate!;
    expect(
      update.featureFlags.firstWhere((f) => f.key == 'social.login.github')
          .enabled,
      isTrue,
    );
    expect(update.rateLimitPerMinute, 100);
    expect(find.text('설정이 저장되었습니다.'), findsOneWidget);
  });

  testWidgets('범위 밖 레이트리밋은 저장하지 않고 안내한다', (tester) async {
    final repository = await pumpScreen(tester);

    await tester.tap(find.text('속도 제한'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('admin-settings-rate-limit')),
      '20000',
    );
    await tester.tap(find.byKey(const Key('admin-settings-save')));
    await tester.pumpAndSettle();

    expect(repository.lastUpdate, isNull);
    expect(find.text('속도 제한은 1~10000 사이여야 합니다.'), findsOneWidget);
  });

  testWidgets('로드 실패 시 에러와 다시 시도를 보여준다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeAdminRepository(settings, failOnGet: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAdminSettingsUseCaseProvider.overrideWithValue(
            GetAdminSettingsUseCase(repository),
          ),
          updateAdminSettingsUseCaseProvider.overrideWithValue(
            UpdateAdminSettingsUseCase(repository),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AdminSystemSettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('시스템 설정을 불러오지 못했습니다.'), findsOneWidget);

    repository.failOnGet = false;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('Free'), findsOneWidget);
  });
}

class _FakeAdminRepository implements AdminRepository {
  _FakeAdminRepository(this.settings, {this.failOnGet = false});

  final AdminSettings settings;
  bool failOnGet;
  AdminSettingsUpdate? lastUpdate;

  @override
  Future<AdminSettings> getSettings() async {
    if (failOnGet) throw Exception('network');
    return settings;
  }

  @override
  Future<AdminSettings> updateSettings(AdminSettingsUpdate update) async {
    lastUpdate = update;
    return AdminSettings(
      planQuotas: settings.planQuotas,
      featureFlags: update.featureFlags,
      rateLimitPerMinute: update.rateLimitPerMinute,
      updatedAt: settings.updatedAt,
    );
  }

  @override
  Future<AdminAnalyticsSummary> getAnalyticsSummary() =>
      throw UnimplementedError();

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
}
