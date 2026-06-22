import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/engagement/data/engagement_api.dart';

void main() {
  test('getGamificationProfile maps /api/v1/gamification/me', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'GET');
        expect(options.path, '/api/v1/gamification/me');
        return _json({
          'xp': 1240,
          'level': 5,
          'currentStreak': 4,
          'longestStreak': 9,
          'badges': [
            {
              'code': 'FIRST_XP',
              'name': 'First XP',
              'description': 'Earn XP',
              'conditionType': 'TOTAL_XP',
              'conditionValue': 1,
              'earnedAt': '2026-06-22T01:00:00Z',
            },
          ],
        });
      });

    final profile = await EngagementApi(dio).getGamificationProfile();

    expect(profile.xp, 1240);
    expect(profile.level, 5);
    expect(profile.remainingXp, 360);
    expect(profile.badges.single.earned, isTrue);
  });

  test('shared content search and fork use community share contract', () async {
    final calls = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        calls.add('${options.method} ${options.path}');
        if (options.path == '/api/v1/community/search') {
          expect(options.method, 'GET');
          expect(options.queryParameters['q'], '알고리즘');
          expect(options.queryParameters['contentType'], 'DECK');
          return _json([
            {
              'id': 11,
              'shareToken': 'deck-token-1',
              'contentType': 'DECK',
              'contentId': 101,
              'ownerId': 7,
              'title': '알고리즘 기초 100제',
              'description': '공유 덱',
              'tags': ['알고리즘'],
              'downloadCount': 234,
              'createdAt': '2026-06-21T05:00:00Z',
            },
          ]);
        }
        if (options.path == '/api/v1/community/share/deck-token-1/fork') {
          expect(options.method, 'POST');
          return _json({
            'id': 12,
            'shareToken': 'deck-token-2',
            'contentType': 'DECK',
            'contentId': 101,
            'ownerId': 8,
            'title': '알고리즘 기초 100제',
            'description': '복사본',
            'tags': ['알고리즘'],
            'downloadCount': 0,
          });
        }
        fail('Unexpected request: ${options.method} ${options.path}');
      });

    final api = EngagementApi(dio);
    final results = await api.searchSharedContent(
      query: '알고리즘',
      contentType: 'DECK',
    );
    final forked = await api.forkSharedContent(results.single.shareToken);

    expect(results.single.id, '11');
    expect(forked.shareToken, 'deck-token-2');
    expect(calls, [
      'GET /api/v1/community/search',
      'POST /api/v1/community/share/deck-token-1/fork',
    ]);
  });

  test('reports use create/list/moderate endpoints', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        if (options.path == '/api/v1/community/reports') {
          expect(options.method, 'POST');
          final body = options.data as Map<String, dynamic>;
          expect(body['targetType'], 'SHARED_DECK');
          expect(body['targetId'], 11);
          expect(body['reason'], '스팸');
          return _json({
            'id': 501,
            'targetType': 'SHARED_DECK',
            'targetId': 11,
            'reason': '스팸',
            'status': 'PENDING',
            'createdAt': '2026-06-22T03:00:00Z',
          });
        }
        if (options.path == '/api/v1/admin/reports') {
          expect(options.method, 'GET');
          expect(options.queryParameters['status'], 'PENDING');
          return _json([
            {
              'id': 501,
              'targetType': 'SHARED_DECK',
              'targetId': 11,
              'reason': '스팸',
              'status': 'PENDING',
              'createdAt': '2026-06-22T03:00:00Z',
            },
          ]);
        }
        if (options.path == '/api/v1/admin/reports/501') {
          expect(options.method, 'PATCH');
          expect((options.data as Map<String, dynamic>)['status'], 'APPROVED');
          return _json({
            'id': 501,
            'targetType': 'SHARED_DECK',
            'targetId': 11,
            'reason': '스팸',
            'status': 'APPROVED',
            'adminNote': '승인',
            'createdAt': '2026-06-22T03:00:00Z',
            'resolvedAt': '2026-06-22T04:00:00Z',
          });
        }
        fail('Unexpected request: ${options.method} ${options.path}');
      });

    final api = EngagementApi(dio);
    final created = await api.createReport(
      targetType: 'SHARED_DECK',
      targetId: '11',
      reason: '스팸',
    );
    final reports = await api.getReports();
    final moderated = await api.moderateReport(
      reportId: created.id,
      status: 'APPROVED',
      adminNote: '승인',
    );

    expect(reports.single.targetLabel, '공유 덱 #11');
    expect(moderated.statusLabel, '승인');
  });
}

ResponseBody _json(Object data) {
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
