import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_analytics_summary.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_data_request.dart';
import 'package:synapse_frontend/services/platform/features/admin/domain/entities/admin_settings.dart';

void main() {
  test('listUsers는 검색/상태 쿼리를 전달하고 페이지 응답을 파싱한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/users');
        expect(options.method, 'GET');
        expect(options.queryParameters, {
          'q': 'admin',
          'status': 'active',
          'page': 0,
          'size': 20,
        });
        return _jsonResponse({
          'content': [
            {
              'id': '11111111-1111-1111-1111-111111111111',
              'email': 'admin@synapse.io',
              'displayName': '관리자',
              'status': 'active',
              'createdAt': '2026-01-01T00:00:00Z',
              'suspendedAt': null,
            },
          ],
          'page': 0,
          'size': 20,
          'totalElements': 1,
          'totalPages': 1,
        });
      });

    final page = await AdminRemoteDatasource(dio)
        .listUsers(query: 'admin', status: 'active');

    expect(page.content.single.email, 'admin@synapse.io');
    expect(page.content.single.status, 'active');
    expect(page.totalElements, 1);
  });

  test('changeUserStatus는 상태를 소문자로 보내고, deleteUser는 DELETE한다', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        requests.add(options);
        return ResponseBody.fromString('', 204);
      });
    final datasource = AdminRemoteDatasource(dio);

    await datasource.changeUserStatus(
      '11111111-1111-1111-1111-111111111111',
      'SUSPENDED',
    );
    await datasource.deleteUser('11111111-1111-1111-1111-111111111111');

    expect(
      requests[0].path,
      '/api/v1/admin/users/11111111-1111-1111-1111-111111111111/status',
    );
    expect(requests[0].method, 'PUT');
    expect(requests[0].data, {'status': 'suspended'});
    expect(
      requests[1].path,
      '/api/v1/admin/users/11111111-1111-1111-1111-111111111111',
    );
    expect(requests[1].method, 'DELETE');
  });

  test('listTenants는 테넌트 페이지 응답을 파싱한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/tenants');
        expect(options.method, 'GET');
        expect(options.queryParameters, {'page': 1, 'size': 10});
        return _jsonResponse({
          'content': [
            {
              'id': '22222222-2222-2222-2222-222222222222',
              'name': 'Synapse',
              'slug': 'synapse',
              'plan': 'pro',
              'status': 'active',
              'createdAt': '2026-01-02T00:00:00Z',
            },
          ],
          'page': 1,
          'size': 10,
          'totalElements': 12,
          'totalPages': 2,
        });
      });

    final page = await AdminRemoteDatasource(dio).listTenants(page: 1, size: 10);

    expect(page.content.single.slug, 'synapse');
    expect(page.page, 1);
    expect(page.totalPages, 2);
  });

  test('changeTenantStatus는 상태를 소문자로 보낸다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(
          options.path,
          '/api/v1/admin/tenants/22222222-2222-2222-2222-222222222222/status',
        );
        expect(options.method, 'PUT');
        expect(options.data, {'status': 'active'});
        return ResponseBody.fromString('', 204);
      });

    await AdminRemoteDatasource(dio)
        .changeTenantStatus('22222222-2222-2222-2222-222222222222', 'ACTIVE');
  });

  test('listAuditLogs는 action/userId 쿼리를 전달하고 Spring Page(number)를 파싱한다',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/audit-logs');
        expect(options.method, 'GET');
        expect(options.queryParameters, {
          'action': 'USER_REGISTERED',
          'userId': '11111111-1111-1111-1111-111111111111',
          'page': 0,
          'size': 20,
        });
        return _jsonResponse({
          'content': [
            {
              'id': '33333333-3333-3333-3333-333333333333',
              'eventId': '44444444-4444-4444-4444-444444444444',
              'action': 'USER_REGISTERED',
              'userId': '11111111-1111-1111-1111-111111111111',
              'resourceType': 'USER',
              'resourceId': '11111111-1111-1111-1111-111111111111',
              'oldValue': null,
              'newValue': '{}',
              'ipAddress': '127.0.0.1',
              'userAgent': 'test',
              'createdAt': '2026-01-03T00:00:00Z',
            },
          ],
          'number': 0,
          'size': 20,
          'totalElements': 1,
          'totalPages': 1,
        });
      });

    final page = await AdminRemoteDatasource(dio).listAuditLogs(
      action: 'USER_REGISTERED',
      userId: '11111111-1111-1111-1111-111111111111',
    );

    expect(page.content.single.action, 'USER_REGISTERED');
    expect(page.content.single.toEntity().targetLabel,
        'USER:11111111-1111-1111-1111-111111111111');
    expect(page.page, 0);
  });

  test('getAnalyticsSummary는 분석 요약 응답을 엔티티로 파싱한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/analytics/summary');
        expect(options.method, 'GET');
        return _jsonResponse({
          'generatedAt': '2026-06-10T12:00:00Z',
          'users': {
            'total': 1200,
            'active': 1100,
            'suspended': 50,
            'deleted': 50,
            'newToday': 12,
            'dau': 340,
            'mau': 980,
            'activitySource': 'USERS_LAST_LOGIN_AT',
          },
          'tenants': {
            'total': 80,
            'active': 75,
            'suspended': 5,
            'plans': {'free': 60, 'pro': 20},
          },
          'usage': [
            {
              'key': 'notifications.sent.today',
              'label': '오늘 발송 알림',
              'value': 152,
              'unit': 'count',
              'status': 'OK',
              'source': 'notifications',
            },
            {
              'key': 'ai.tokens.monthly',
              'label': 'AI 토큰',
              'value': null,
              'unit': 'tokens',
              'status': 'NOT_CONNECTED',
              'source': 'learning-ai',
            },
          ],
          'pendingItems': [
            {
              'key': 'data-requests',
              'label': 'GDPR 요청',
              'count': null,
              'severity': 'INFO',
              'status': 'NOT_IMPLEMENTED',
            },
          ],
          'recentActivities': [
            {
              'id': '33333333-3333-3333-3333-333333333333',
              'action': 'USER_REGISTERED',
              'userId': '11111111-1111-1111-1111-111111111111',
              'resourceType': 'USER',
              'resourceId': '11111111-1111-1111-1111-111111111111',
              'createdAt': '2026-06-10T11:55:00Z',
            },
          ],
        });
      });

    final summary =
        (await AdminRemoteDatasource(dio).getAnalyticsSummary()).toEntity();

    expect(summary.users.total, 1200);
    expect(summary.users.dau, 340);
    expect(summary.users.mau, 980);
    expect(summary.tenants.plans, {'free': 60, 'pro': 20});
    expect(summary.usage.first.value, 152);
    expect(summary.usage.first.status, AdminMetricStatus.ok);
    expect(summary.usage.last.value, isNull);
    expect(summary.usage.last.status, AdminMetricStatus.notConnected);
    expect(
      summary.pendingItems.single.status,
      AdminMetricStatus.notImplemented,
    );
    expect(summary.recentActivities.single.action, 'USER_REGISTERED');
    expect(summary.recentActivities.single.createdAt, isNotNull);
  });

  test('getSettings는 설정 응답을 엔티티로 파싱한다(null=무제한)', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/settings');
        expect(options.method, 'GET');
        return _jsonResponse({
          'planQuotas': [
            {
              'planCode': 'free',
              'displayName': 'Free',
              'maxNotes': 100,
              'maxCards': 1000,
              'maxStorageBytes': 1073741824,
              'maxAiTokensMonthly': 1000,
              'maxAiCardGenerationsMonthly': 20,
              'maxUsersPerTenant': 5,
            },
            {
              'planCode': 'enterprise',
              'displayName': 'Enterprise',
              'maxNotes': null,
              'maxCards': null,
              'maxStorageBytes': null,
              'maxAiTokensMonthly': null,
              'maxAiCardGenerationsMonthly': null,
              'maxUsersPerTenant': null,
            },
          ],
          'featureFlags': [
            {'key': 'ai.card.generation', 'label': 'AI 카드 생성', 'enabled': true},
            {'key': 'social.login.github', 'label': 'GitHub 로그인', 'enabled': false},
          ],
          'rateLimit': {'apiRequestsPerMinute': 100},
          'updatedAt': '2026-06-10T12:00:00Z',
        });
      });

    final settings = (await AdminRemoteDatasource(dio).getSettings()).toEntity();

    expect(settings.planQuotas, hasLength(2));
    expect(settings.planQuotas.first.maxStorageBytes, 1073741824);
    expect(settings.planQuotas.last.maxNotes, isNull);
    expect(settings.featureFlags.first.enabled, isTrue);
    expect(settings.featureFlags.last.enabled, isFalse);
    expect(settings.rateLimitPerMinute, 100);
    expect(settings.updatedAt, isNotNull);
  });

  test('updateSettings는 플래그와 레이트리밋만 PUT 페이로드로 보낸다', () async {
    late Map<String, dynamic> sentBody;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/settings');
        expect(options.method, 'PUT');
        sentBody = options.data as Map<String, dynamic>;
        return _jsonResponse({
          'planQuotas': const [],
          'featureFlags': [
            {'key': 'ai.card.generation', 'label': 'AI 카드 생성', 'enabled': false},
          ],
          'rateLimit': {'apiRequestsPerMinute': 200},
          'updatedAt': '2026-06-10T13:00:00Z',
        });
      });

    final saved = await AdminRemoteDatasource(dio).updateSettings(
      const AdminSettingsUpdate(
        featureFlags: [
          AdminFeatureFlag(
            key: 'ai.card.generation',
            label: 'AI 카드 생성',
            enabled: false,
          ),
        ],
        rateLimitPerMinute: 200,
      ),
    );

    expect(sentBody, {
      'featureFlags': [
        {'key': 'ai.card.generation', 'enabled': false},
      ],
      'rateLimit': {'apiRequestsPerMinute': 200},
    });
    expect(saved.toEntity().rateLimitPerMinute, 200);
  });

  test('AdminMetricStatus.parse는 ACTION_REQUIRED를 인식한다', () {
    expect(
      AdminMetricStatus.parse('ACTION_REQUIRED'),
      AdminMetricStatus.actionRequired,
    );
    expect(AdminMetricStatus.actionRequired.hasValue, isTrue);
    expect(AdminMetricStatus.notConnected.hasValue, isFalse);
  });

  test('listDataRequests는 status/q 쿼리를 전달하고 페이지를 파싱한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/data-requests');
        expect(options.method, 'GET');
        expect(options.queryParameters, {
          'status': 'PENDING',
          'q': 'user@example.com',
          'page': 0,
          'size': 20,
        });
        return _jsonResponse({
          'content': [
            {
              'id': '55555555-5555-5555-5555-555555555555',
              'userId': '11111111-1111-1111-1111-111111111111',
              'userEmail': 'user@example.com',
              'userDisplayName': '사용자',
              'type': 'DATA_ERASURE',
              'typeLabel': '데이터 삭제',
              'status': 'PENDING',
              'statusLabel': '대기',
              'receivedAt': '2026-06-11T01:00:00Z',
              'dueAt': '2026-07-11T01:00:00Z',
              'daysRemaining': 29,
              'processedAt': null,
              'reason': '본인 요청',
              'adminNote': null,
              'dataSummary': null,
              'latestLog': '2026-06-11 접수',
              'executionLogs': ['2026-06-11 접수'],
            },
          ],
          'page': 0,
          'size': 20,
          'totalElements': 1,
          'totalPages': 1,
        });
      });

    final page = await AdminRemoteDatasource(dio).listDataRequests(
      status: 'PENDING',
      query: 'user@example.com',
    );
    final request = page.content.single.toEntity();

    expect(request.type, AdminDataRequestType.dataErasure);
    expect(request.status, AdminDataRequestStatus.pending);
    expect(request.typeLabel, '데이터 삭제');
    expect(request.daysRemaining, 29);
    expect(request.executionLogs, ['2026-06-11 접수']);
    expect(request.canApprove, isTrue);
    expect(request.canExecute, isFalse); // ERASURE는 즉시 실행 불가
  });

  test('applyDataRequestAction은 액션 페이로드를 보내고 409를 충돌 예외로 변환한다', () async {
    late Map<String, dynamic> sentBody;
    var fail409 = false;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(
          options.path,
          '/api/v1/admin/data-requests/55555555-5555-5555-5555-555555555555/actions',
        );
        if (fail409) {
          return ResponseBody.fromString(
            jsonEncode({'status': 409, 'detail': 'conflict'}),
            409,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        sentBody = options.data as Map<String, dynamic>;
        return _jsonResponse({
          'id': '55555555-5555-5555-5555-555555555555',
          'status': 'PROCESSING',
          'statusLabel': '처리중',
          'type': 'DATA_ACCESS',
          'typeLabel': '데이터 열람',
          'executionLogs': const [],
        });
      });
    final datasource = AdminRemoteDatasource(dio);

    final updated = await datasource.applyDataRequestAction(
      id: '55555555-5555-5555-5555-555555555555',
      action: 'APPROVE',
      reason: '확인 완료',
    );

    expect(sentBody, {'action': 'APPROVE', 'reason': '확인 완료'});
    expect(updated.toEntity().status, AdminDataRequestStatus.processing);

    fail409 = true;
    await expectLater(
      datasource.applyDataRequestAction(
        id: '55555555-5555-5555-5555-555555555555',
        action: 'EXECUTE',
      ),
      throwsA(isA<AdminDataRequestConflictException>()),
    );
  });

  test('createDataRequest는 userId/type/reason을 POST한다', () async {
    late Map<String, dynamic> sentBody;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/api/v1/admin/data-requests');
        expect(options.method, 'POST');
        sentBody = options.data as Map<String, dynamic>;
        return _jsonResponse({
          'id': '66666666-6666-6666-6666-666666666666',
          'status': 'PENDING',
          'statusLabel': '대기',
          'type': 'DATA_EXPORT',
          'typeLabel': '데이터 내보내기',
          'executionLogs': const [],
        });
      });

    final created = await AdminRemoteDatasource(dio).createDataRequest(
      userId: '11111111-1111-1111-1111-111111111111',
      type: 'DATA_EXPORT',
      reason: '사용자 메일 요청',
    );

    expect(sentBody, {
      'userId': '11111111-1111-1111-1111-111111111111',
      'type': 'DATA_EXPORT',
      'reason': '사용자 메일 요청',
    });
    expect(created.toEntity().status, AdminDataRequestStatus.pending);
  });
}

ResponseBody _jsonResponse(Map<String, Object?> data) {
  return ResponseBody.fromString(
    jsonEncode(data),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
