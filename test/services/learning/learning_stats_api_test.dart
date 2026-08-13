import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';

const _tenantId = '00000000-0000-0000-0000-000000000099';

void main() {
  test('getForecast가 구간 파라미터를 보내고 overdue/days를 파싱한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'GET');
        expect(options.path, '/stats/forecast');
        expect(options.queryParameters['from'], '2026-08-13');
        expect(options.queryParameters['to'], '2026-08-15');
        expect(options.headers['X-Tenant-Id'], _tenantId);
        return _json({
          'overdueCount': 7,
          'days': [
            {'date': '2026-08-13', 'dueCount': 12},
            {'date': '2026-08-14', 'dueCount': 0},
            {'date': '2026-08-15', 'dueCount': 3},
          ],
        });
      });

    final forecast = await LearningStatsApi(dio).getForecast(
      tenantId: _tenantId,
      from: DateTime(2026, 8, 13),
      to: DateTime(2026, 8, 15),
    );

    expect(forecast.overdueCount, 7);
    expect(forecast.days, hasLength(3));
    expect(forecast.days.first.date, DateTime(2026, 8, 13));
    expect(forecast.days.first.dueCount, 12);
    expect(forecast.maxDueCount, 12);
  });

  test('getDeckSummaries가 date를 보내고 덱 집계를 파싱한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/stats/decks');
        expect(options.queryParameters['date'], '2026-08-13');
        return _json({
          'decks': [
            {
              'deckId': '00000000-0000-0000-0000-0000000000aa',
              'name': 'AWS SAA',
              'totalCards': 40,
              'unreviewedCards': 5,
              'dueCount': 5,
              'reviewedCount': 0,
            },
          ],
        });
      });

    final decks = await LearningStatsApi(dio).getDeckSummaries(
      tenantId: _tenantId,
      date: DateTime(2026, 8, 13),
    );

    expect(decks, hasLength(1));
    expect(decks.first.deckId, '00000000-0000-0000-0000-0000000000aa');
    expect(decks.first.name, 'AWS SAA');
    expect(decks.first.totalCards, 40);
    expect(decks.first.unreviewedCards, 5);
    expect(decks.first.dueCount, 5);
    expect(decks.first.reviewedCount, 0);
  });

  test('getDeckSummaries가 date 없으면 파라미터를 생략한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.queryParameters.containsKey('date'), isFalse);
        return _json({'decks': <dynamic>[]});
      });

    final decks = await LearningStatsApi(dio).getDeckSummaries(tenantId: _tenantId);

    expect(decks, isEmpty);
  });

  test('getDailyStats가 일별 실적을 파싱한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.path, '/stats/daily');
        return _json({
          'days': [
            {'date': '2026-08-12', 'reviewCount': 23, 'correctRate': 87.0},
          ],
        });
      });

    final days = await LearningStatsApi(dio).getDailyStats(
      tenantId: _tenantId,
      from: DateTime(2026, 8, 12),
      to: DateTime(2026, 8, 13),
    );

    expect(days, hasLength(1));
    expect(days.first.reviewCount, 23);
    expect(days.first.correctRate, 87.0);
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
