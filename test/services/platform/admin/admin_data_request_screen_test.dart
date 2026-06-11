import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_analytics_summary.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_audit_log.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_data_request.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_page.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_settings.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_tenant.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_user.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/repositories/admin_repository.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/usecases/admin_data_request_usecases.dart';
import 'package:synapse_frontend/services/platform/features/admin/presentation/screens/admin_screens.dart';
import 'package:synapse_frontend/services/platform/features/admin/providers/admin_providers.dart';

AdminDataRequest request({
  String id = 'r1',
  AdminDataRequestType type = AdminDataRequestType.dataAccess,
  String typeLabel = '데이터 열람',
  AdminDataRequestStatus status = AdminDataRequestStatus.pending,
  String statusLabel = '대기',
}) {
  return AdminDataRequest(
    id: id,
    userId: '11111111-1111-1111-1111-111111111111',
    userEmail: 'user@example.com',
    userDisplayName: '사용자',
    type: type,
    typeLabel: typeLabel,
    status: status,
    statusLabel: statusLabel,
    receivedAt: DateTime(2026, 6, 11),
    dueAt: DateTime(2026, 7, 11),
    daysRemaining: 29,
    executionLogs: const ['2026-06-11 접수'],
  );
}

void main() {
  Future<_FakeAdminRepository> pumpScreen(
    WidgetTester tester,
    List<AdminDataRequest> requests,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1300, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeAdminRepository(requests);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listAdminDataRequestsUseCaseProvider.overrideWithValue(
            ListAdminDataRequestsUseCase(repository),
          ),
          createAdminDataRequestUseCaseProvider.overrideWithValue(
            CreateAdminDataRequestUseCase(repository),
          ),
          applyAdminDataRequestActionUseCaseProvider.overrideWithValue(
            ApplyAdminDataRequestActionUseCase(repository),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AdminDataRequestScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('목록을 렌더하고 행 선택 시 상세를 보여준다', (tester) async {
    await pumpScreen(tester, [request()]);

    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('데이터 열람'), findsOneWidget);

    await tester.tap(find.text('user@example.com'));
    await tester.pumpAndSettle();

    expect(find.text('요청 상세'), findsOneWidget);
    expect(find.text('2026-06-11 접수'), findsOneWidget);
    expect(find.textContaining('처리 기한'), findsOneWidget);
  });

  testWidgets('승인 시 사유와 함께 액션을 호출하고 행 상태를 갱신한다', (tester) async {
    final repository = await pumpScreen(tester, [request()]);

    await tester.tap(find.text('user@example.com'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dr-action-approve')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('dr-reason-field')),
      '신원 확인 완료',
    );
    await tester.tap(find.byKey(const Key('dr-reason-confirm')));
    await tester.pumpAndSettle();

    expect(repository.lastActionId, 'r1');
    expect(repository.lastAction, AdminDataRequestAction.approve);
    expect(repository.lastActionReason, '신원 확인 완료');
    // 응답으로 행이 갱신되어 처리중 상태가 표시된다.
    expect(find.text('처리중'), findsWidgets);
  });

  testWidgets('삭제(ERASURE) 요청은 처리중이어도 실행 버튼이 비활성이다', (tester) async {
    await pumpScreen(tester, [
      request(
        type: AdminDataRequestType.dataErasure,
        typeLabel: '데이터 삭제',
        status: AdminDataRequestStatus.processing,
        statusLabel: '처리중',
      ),
    ]);

    await tester.tap(find.text('user@example.com'));
    await tester.pumpAndSettle();

    final execute = tester.widget<OutlinedButton>(
      find.byKey(const Key('dr-action-execute')),
    );
    expect(execute.onPressed, isNull);
    // 승인 버튼은 PENDING 전용이라 없음, 거부는 가능.
    expect(find.byKey(const Key('dr-action-approve')), findsNothing);
    expect(find.byKey(const Key('dr-action-reject')), findsOneWidget);
  });

  testWidgets('상태 필터 선택을 서버 쿼리로 전달한다', (tester) async {
    final repository = await pumpScreen(tester, [request()]);

    await tester.tap(find.widgetWithText(FilterChip, '처리중'));
    await tester.pumpAndSettle();

    expect(repository.lastListStatus, AdminDataRequestStatus.processing);
  });

  testWidgets('요청 등록 다이얼로그가 createDataRequest를 호출한다', (tester) async {
    final repository = await pumpScreen(tester, [request()]);

    await tester.tap(find.byKey(const Key('data-request-create')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('dr-create-user-id')),
      '22222222-2222-2222-2222-222222222222',
    );
    await tester.tap(find.byKey(const Key('dr-create-submit')));
    await tester.pumpAndSettle();

    expect(
      repository.lastCreateUserId,
      '22222222-2222-2222-2222-222222222222',
    );
    expect(repository.lastCreateType, AdminDataRequestType.dataAccess);
  });
}

class _FakeAdminRepository implements AdminRepository {
  _FakeAdminRepository(this.requests);

  List<AdminDataRequest> requests;
  AdminDataRequestStatus? lastListStatus;
  String? lastListQuery;
  String? lastActionId;
  AdminDataRequestAction? lastAction;
  String? lastActionReason;
  String? lastCreateUserId;
  AdminDataRequestType? lastCreateType;

  @override
  Future<AdminPage<AdminDataRequest>> listDataRequests({
    AdminDataRequestStatus? status,
    String? query,
    int page = 0,
    int size = 20,
  }) async {
    lastListStatus = status;
    lastListQuery = query;
    return AdminPage<AdminDataRequest>(
      content: requests,
      page: page,
      size: size,
      totalElements: requests.length,
      totalPages: 1,
    );
  }

  @override
  Future<AdminDataRequest> createDataRequest({
    required String userId,
    required AdminDataRequestType type,
    String? reason,
  }) async {
    lastCreateUserId = userId;
    lastCreateType = type;
    return requests.first;
  }

  @override
  Future<AdminDataRequest> applyDataRequestAction({
    required String id,
    required AdminDataRequestAction action,
    String? reason,
  }) async {
    lastActionId = id;
    lastAction = action;
    lastActionReason = reason;
    return request(
      id: id,
      status: AdminDataRequestStatus.processing,
      statusLabel: '처리중',
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

  @override
  Future<AdminSettings> getSettings() => throw UnimplementedError();

  @override
  Future<AdminSettings> updateSettings(AdminSettingsUpdate update) =>
      throw UnimplementedError();
}
