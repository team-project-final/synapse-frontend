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

  test('getGroupSharedContent가 그룹 공유 목록을 반환한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'GET');
        expect(options.path, '/api/v1/community/groups/7/shared-content');
        expect(options.queryParameters['q'], '알고리즘');
        expect(options.queryParameters['contentType'], 'DECK');
        return _json([
          {
            'id': 1,
            'shareToken': 'tok',
            'contentType': 'DECK',
            'contentId': 9,
            'ownerId': 3,
            'title': 'Group Deck',
            'description': null,
            'tags': <String>[],
            'downloadCount': 0,
            'sourceShareId': null,
            'createdAt': '2026-08-01T00:00:00Z',
            'groupId': 7,
          },
        ]);
      });

    final result = await EngagementApi(
      dio,
    ).getGroupSharedContent('7', keyword: '알고리즘', contentType: 'DECK');

    expect(result, hasLength(1));
    expect(result.first.title, 'Group Deck');
    expect(result.first.groupId, '7');
  });

  test('shareContent가 groupId를 요청 본문에 싣는다', () async {
    late Map<String, dynamic> body;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'POST');
        expect(options.path, '/api/v1/community/share');
        body = options.data as Map<String, dynamic>;
        return _json({
          'shareToken': 'tok',
          'shareUrl': 'https://synapse.local/share/tok',
        });
      });

    await EngagementApi(dio).shareContent(
      contentType: 'DECK',
      contentId: '101',
      title: '그룹 전용 덱',
      description: '스터디 그룹 내부 공유',
      groupId: '7',
    );

    expect(body['groupId'], 7);
  });

  test('shareContent가 groupId 없으면 본문에서 생략한다', () async {
    late Map<String, dynamic> body;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        body = options.data as Map<String, dynamic>;
        return _json({
          'shareToken': 'tok',
          'shareUrl': 'https://synapse.local/share/tok',
        });
      });

    await EngagementApi(dio).shareContent(
      contentType: 'DECK',
      contentId: '101',
      title: '공개 덱',
      description: '누구나 열람',
    );

    expect(body.containsKey('groupId'), isFalse);
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

  test('community groups use group list/detail/member contracts', () async {
    final calls = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        calls.add('${options.method} ${options.path}');
        if (options.path == '/api/v1/community/groups') {
          expect(options.method, 'GET');
          expect(options.queryParameters['page'], 0);
          expect(options.queryParameters['size'], 10);
          return _json([
            {
              'id': 1,
              'name': 'AWS 자격증 스터디',
              'description': '클라우드 자격증 준비',
              'isPublic': false,
              'ownerId': 100,
              'createdAt': '2026-06-21T05:00:00Z',
            },
          ]);
        }
        if (options.path == '/api/v1/community/groups/1') {
          expect(options.method, 'GET');
          return _json({
            'id': 1,
            'name': 'AWS 자격증 스터디',
            'description': '클라우드 자격증 준비',
            'isPublic': false,
            'ownerId': 100,
            'createdAt': '2026-06-21T05:00:00Z',
          });
        }
        if (options.path == '/api/v1/community/groups/1/members') {
          expect(options.method, 'GET');
          return _json([
            {
              'id': 500,
              'groupId': 1,
              'userId': 100,
              'role': 'OWNER',
              'status': 'ACTIVE',
              'joinedAt': '2026-06-21T05:00:00Z',
            },
          ]);
        }
        if (options.path == '/api/v1/community/groups/1/members/join') {
          expect(options.method, 'POST');
          return _json({
            'id': 501,
            'groupId': 1,
            'userId': 101,
            'role': 'MEMBER',
            'status': 'PENDING',
            'joinedAt': '2026-06-22T04:00:00Z',
          });
        }
        fail('Unexpected request: ${options.method} ${options.path}');
      });

    final api = EngagementApi(dio);
    final groups = await api.getGroups(size: 10);
    final group = await api.getGroup(groups.single.id);
    final members = await api.getGroupMembers(group.id);
    final joined = await api.joinGroup(group.id);

    expect(group.name, 'AWS 자격증 스터디');
    expect(group.visibilityLabel, '비공개');
    expect(members.single.roleLabel, '소유자');
    expect(joined.statusLabel, '대기');
    expect(calls, [
      'GET /api/v1/community/groups',
      'GET /api/v1/community/groups/1',
      'GET /api/v1/community/groups/1/members',
      'POST /api/v1/community/groups/1/members/join',
    ]);
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
