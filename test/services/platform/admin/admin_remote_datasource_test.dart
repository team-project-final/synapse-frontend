import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/admin/data/datasources/admin_remote_datasource.dart';

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
