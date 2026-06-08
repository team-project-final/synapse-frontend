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
