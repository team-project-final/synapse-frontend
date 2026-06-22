import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/knowledge/data/knowledge_api.dart';

void main() {
  test('listNotes maps ApiResponse Spring page envelope', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'GET');
        expect(options.path, '/api/v1/notes');
        expect(options.queryParameters['tag'], '머신러닝');
        expect(options.queryParameters['sort'], 'updatedAt,desc');
        return _json({
          'success': true,
          'data': {
            'content': [
              {
                'id': 1,
                'title': '정규화 기법',
                'contentMd': '본문',
                'contentPlain': '본문',
                'tags': ['머신러닝'],
                'status': 'ACTIVE',
                'updatedAt': '2026-06-21T08:00:00Z',
              },
            ],
            'totalElements': 1,
            'totalPages': 1,
            'number': 0,
            'size': 20,
          },
        });
      });

    final page = await KnowledgeApi(
      dio,
    ).listNotes(tag: '머신러닝', sort: 'updatedAt,desc');

    expect(page.totalElements, 1);
    expect(page.items.single.id, '1');
    expect(page.items.single.tags, ['머신러닝']);
  });

  test('createNote posts tenant-scoped note payload', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'POST');
        expect(options.path, '/api/v1/notes');
        final body = options.data as Map<String, dynamic>;
        expect(body['tenantId'], 'tenant-1');
        expect(body['title'], '새 노트');
        expect(body['tags'], ['api']);
        return _json({
          'success': true,
          'data': {
            'id': 99,
            'title': '새 노트',
            'contentMd': '# 본문',
            'contentPlain': '본문',
            'tags': ['api'],
            'status': 'ACTIVE',
          },
        });
      });

    final note = await KnowledgeApi(dio).createNote(
      tenantId: 'tenant-1',
      title: '새 노트',
      contentMd: '# 본문',
      tags: const ['api'],
    );

    expect(note.id, '99');
    expect(note.title, '새 노트');
  });

  test('hybridSearch maps unified search response', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'POST');
        expect(options.path, '/api/v1/ai/search/hybrid');
        final body = options.data as Map<String, dynamic>;
        expect(body['query'], 'regularization');
        return _json({
          'success': true,
          'data': {
            'results': [
              {
                'noteId': 1,
                'title': '정규화 기법',
                'snippet': '과적합을 줄입니다.',
                'rrfScore': 0.88,
              },
            ],
            'totalCount': 1,
            'hasNext': false,
            'searchTimeMs': 13,
            'semanticFallback': false,
          },
        });
      });

    final page = await KnowledgeApi(dio).hybridSearch(query: 'regularization');

    expect(page.totalCount, 1);
    expect(page.searchTimeMs, 13);
    expect(page.results.single.noteId, '1');
    expect(page.results.single.score, 0.88);
  });

  test('getGraphData maps graph nodes and edges', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _FakeAdapter((options) {
        expect(options.method, 'GET');
        expect(options.path, '/api/v1/graph/data');
        return _json({
          'success': true,
          'data': {
            'nodes': [
              {'id': 1, 'title': '정규화 기법', 'linkCount': 6, 'pageRank': 0.85},
            ],
            'edges': [
              {'source': 1, 'target': 2, 'type': 'WIKI_LINK'},
            ],
          },
        });
      });

    final graph = await KnowledgeApi(dio).getGraphData();

    expect(graph.nodes.single.id, '1');
    expect(graph.nodes.single.label, '정규화 기법');
    expect(graph.edges.single.from, '1');
    expect(graph.edges.single.to, '2');
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
