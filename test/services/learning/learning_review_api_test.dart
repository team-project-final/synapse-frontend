import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/learning_review_api.dart';

void main() {
  test('listDecks maps ApiResponse page envelope and tenant header', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8084'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'GET');
        expect(options.path, '/decks');
        expect(options.headers['X-Tenant-Id'], 'tenant-1');
        expect(options.queryParameters['page'], 0);
        return _json({
          'data': {
            'content': [
              {
                'id': 'deck-1',
                'name': 'Java',
                'description': 'Spring cards',
                'color': '#66AAFF',
              },
            ],
            'page': 0,
            'size': 20,
            'totalElements': 1,
            'totalPages': 1,
            'last': true,
          },
        });
      });

    final page = await LearningReviewApi(dio).listDecks(tenantId: 'tenant-1');

    expect(page.totalElements, 1);
    expect(page.items.single.id, 'deck-1');
    expect(page.items.single.name, 'Java');
  });

  test('review session flow posts backend contract payloads', () async {
    final calls = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8084'))
      ..httpClientAdapter = _FakeAdapter((options) {
        calls.add('${options.method} ${options.path}');
        expect(options.headers['X-Tenant-Id'], 'tenant-1');

        if (options.path == '/reviews/sessions') {
          expect(options.method, 'POST');
          expect((options.data as Map<String, dynamic>)['deckId'], 'deck-1');
          return _json({
            'data': {
              'sessionId': 'session-1',
              'deckId': 'deck-1',
              'status': 'in_progress',
              'totalCards': 1,
              'reviewedCards': 0,
            },
          });
        }

        if (options.path == '/reviews/queue') {
          expect(options.method, 'GET');
          expect(options.queryParameters['deckId'], 'deck-1');
          return _json({
            'data': [
              {
                'cardId': 'card-1',
                'cardType': 'qa',
                'frontContent': '스택이란?',
                'backContent': 'LIFO',
                'bloomLevel': 'remember',
                'repetitions': 1,
                'easinessFactor': 2.5,
              },
            ],
          });
        }

        if (options.path == '/reviews/sessions/session-1/submit') {
          expect(options.method, 'POST');
          final body = options.data as Map<String, dynamic>;
          expect(body['cardId'], 'card-1');
          expect(body['rating'], 3);
          expect(body['timeSpentMs'], 1200);
          return _json({
            'data': {
              'cardId': 'card-1',
              'rating': 3,
              'newEaseFactor': 2.5,
              'newIntervalDays': 1,
              'lapses': 0,
            },
          });
        }

        if (options.path == '/reviews/sessions/session-1/complete') {
          expect(options.method, 'PUT');
          return _json({
            'data': {
              'sessionId': 'session-1',
              'deckId': 'deck-1',
              'status': 'completed',
              'totalCards': 1,
              'reviewedCards': 1,
            },
          });
        }

        fail('Unexpected request: ${options.method} ${options.path}');
      });

    final api = LearningReviewApi(dio);
    final session = await api.startSession(
      tenantId: 'tenant-1',
      deckId: 'deck-1',
    );
    final queue = await api.getReviewQueue(
      tenantId: 'tenant-1',
      deckId: 'deck-1',
    );
    final result = await api.submitReview(
      tenantId: 'tenant-1',
      sessionId: session.id,
      cardId: queue.single.id,
      rating: 3,
      timeSpentMs: 1200,
    );
    final completed = await api.completeSession(
      tenantId: 'tenant-1',
      sessionId: session.id,
    );

    expect(queue.single.frontContent, '스택이란?');
    expect(result.newIntervalDays, 1);
    expect(completed.status, 'completed');
    expect(calls, [
      'POST /reviews/sessions',
      'GET /reviews/queue',
      'POST /reviews/sessions/session-1/submit',
      'PUT /reviews/sessions/session-1/complete',
    ]);
  });
}

ResponseBody _json(Map<String, dynamic> data) {
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
