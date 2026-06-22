import 'dart:math' as math;

import 'package:dio/dio.dart';

class KnowledgeNote {
  const KnowledgeNote({
    required this.id,
    required this.title,
    required this.contentMd,
    required this.contentPlain,
    required this.tags,
    required this.status,
    this.deckId,
    this.createdAt,
    this.updatedAt,
  });

  factory KnowledgeNote.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final contentMd = json['contentMd'] ?? json['content'];
    return KnowledgeNote(
      id: _stringId(id),
      title: title is String && title.isNotEmpty ? title : '제목 없는 노트',
      contentMd: contentMd is String ? contentMd : '',
      contentPlain: (json['contentPlain'] as String?) ?? '',
      tags: _stringList(json['tags']),
      deckId: json['deckId'] as String?,
      status: (json['status'] as String?) ?? 'ACTIVE',
      createdAt: _dateTimeValue(json['createdAt']),
      updatedAt: _dateTimeValue(json['updatedAt']),
    );
  }

  final String id;
  final String title;
  final String contentMd;
  final String contentPlain;
  final List<String> tags;
  final String? deckId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get snippet {
    final source = contentPlain.isNotEmpty ? contentPlain : contentMd;
    final collapsed = source.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length <= 140) return collapsed;
    return '${collapsed.substring(0, 140)}...';
  }

  String get updatedLabel => _relativeDate(updatedAt ?? createdAt);
}

class KnowledgeNotePage {
  const KnowledgeNotePage({
    required this.items,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory KnowledgeNotePage.fromJson(Map<String, dynamic> json) {
    final items = _listValue(json['content'] ?? json['items'] ?? json['data'])
        .whereType<Map<String, dynamic>>()
        .map(KnowledgeNote.fromJson)
        .toList(growable: false);
    return KnowledgeNotePage(
      items: items,
      totalElements: _intValue(json['totalElements']) ?? items.length,
      totalPages: _intValue(json['totalPages']) ?? 1,
      page: _intValue(json['number'] ?? json['page']) ?? 0,
      size: _intValue(json['size']) ?? items.length,
    );
  }

  final List<KnowledgeNote> items;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  bool get isEmpty => items.isEmpty;
}

class KnowledgeSearchResult {
  const KnowledgeSearchResult({
    required this.noteId,
    required this.title,
    required this.snippet,
    required this.highlights,
    required this.score,
  });

  factory KnowledgeSearchResult.fromJson(Map<String, dynamic> json) {
    final highlights = _stringList(json['highlights']);
    final snippet =
        (json['snippet'] as String?) ??
        (highlights.isEmpty ? '' : highlights.first);
    final score = _doubleValue(
      json['rrfScore'] ?? json['score'] ?? json['keywordScore'],
    );
    return KnowledgeSearchResult(
      noteId: _stringId(json['noteId'] ?? json['id']),
      title: (json['title'] as String?) ?? '제목 없는 노트',
      snippet: snippet,
      highlights: highlights,
      score: score,
    );
  }

  final String noteId;
  final String title;
  final String snippet;
  final List<String> highlights;
  final double score;
}

class KnowledgeSearchPage {
  const KnowledgeSearchPage({
    required this.results,
    required this.totalCount,
    required this.hasNext,
    this.nextCursor,
    this.searchTimeMs,
    this.semanticFallback = false,
  });

  factory KnowledgeSearchPage.empty() {
    return const KnowledgeSearchPage(
      results: [],
      totalCount: 0,
      hasNext: false,
    );
  }

  factory KnowledgeSearchPage.fromJson(Map<String, dynamic> json) {
    final results = _listValue(json['results'])
        .whereType<Map<String, dynamic>>()
        .map(KnowledgeSearchResult.fromJson)
        .toList(growable: false);
    return KnowledgeSearchPage(
      results: results,
      totalCount: _intValue(json['totalCount']) ?? results.length,
      nextCursor: json['nextCursor'] as String?,
      hasNext: json['hasNext'] == true,
      searchTimeMs: _intValue(json['searchTimeMs']),
      semanticFallback: json['semanticFallback'] == true,
    );
  }

  final List<KnowledgeSearchResult> results;
  final int totalCount;
  final String? nextCursor;
  final bool hasNext;
  final int? searchTimeMs;
  final bool semanticFallback;

  bool get isEmpty => results.isEmpty;
}

class KnowledgeTagStat {
  const KnowledgeTagStat({required this.tag, required this.count});

  factory KnowledgeTagStat.fromJson(Map<String, dynamic> json) {
    return KnowledgeTagStat(
      tag: (json['tag'] as String?) ?? '',
      count: _intValue(json['count']) ?? 0,
    );
  }

  final String tag;
  final int count;
}

class KnowledgeGraphData {
  const KnowledgeGraphData({required this.nodes, required this.edges});

  factory KnowledgeGraphData.empty() {
    return const KnowledgeGraphData(nodes: [], edges: []);
  }

  factory KnowledgeGraphData.fromJson(Map<String, dynamic> json) {
    final rawNodes = _listValue(
      json['nodes'],
    ).whereType<Map<String, dynamic>>().toList(growable: false);
    final count = rawNodes.length;
    const center = math.Point<double>(360, 260);
    final radius = count <= 4 ? 150.0 : 210.0;
    final nodes = <KnowledgeGraphNode>[];

    for (var i = 0; i < rawNodes.length; i++) {
      final node = rawNodes[i];
      final angle = count <= 1 ? 0.0 : (2 * math.pi * i) / count;
      final title = (node['title'] as String?) ?? '노트 ${i + 1}';
      nodes.add(
        KnowledgeGraphNode(
          id: _stringId(node['id']),
          label: title,
          x: center.x + radius * math.cos(angle),
          y: center.y + radius * math.sin(angle),
          cluster: _clusterFor(title),
          linkCount: _intValue(node['linkCount']) ?? 0,
          pageRank: _doubleValue(node['pageRank']),
        ),
      );
    }

    final edges = _listValue(json['edges'])
        .whereType<Map<String, dynamic>>()
        .map(KnowledgeGraphEdge.fromJson)
        .toList(growable: false);
    return KnowledgeGraphData(nodes: nodes, edges: edges);
  }

  final List<KnowledgeGraphNode> nodes;
  final List<KnowledgeGraphEdge> edges;

  bool get isEmpty => nodes.isEmpty;
}

class KnowledgeGraphNode {
  const KnowledgeGraphNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.cluster,
    required this.linkCount,
    required this.pageRank,
  });

  final String id;
  final String label;
  final double x;
  final double y;
  final int cluster;
  final int linkCount;
  final double pageRank;
}

class KnowledgeGraphEdge {
  const KnowledgeGraphEdge({
    required this.from,
    required this.to,
    required this.type,
  });

  factory KnowledgeGraphEdge.fromJson(Map<String, dynamic> json) {
    return KnowledgeGraphEdge(
      from: _stringId(json['source'] ?? json['from']),
      to: _stringId(json['target'] ?? json['to']),
      type: (json['type'] as String?) ?? 'LINK',
    );
  }

  final String from;
  final String to;
  final String type;
}

class KnowledgeNoteVersion {
  const KnowledgeNoteVersion({
    required this.id,
    required this.versionNo,
    required this.title,
    this.contentMd,
    this.createdAt,
  });

  factory KnowledgeNoteVersion.fromJson(Map<String, dynamic> json) {
    return KnowledgeNoteVersion(
      id: _stringId(json['id']),
      versionNo: _intValue(json['versionNo']) ?? 0,
      title: (json['title'] as String?) ?? '버전',
      contentMd: json['contentMd'] as String?,
      createdAt: _dateTimeValue(json['createdAt']),
    );
  }

  final String id;
  final int versionNo;
  final String title;
  final String? contentMd;
  final DateTime? createdAt;
}

class KnowledgeApi {
  const KnowledgeApi(this._dio);

  final Dio _dio;

  Future<KnowledgeNotePage> listNotes({
    String? tag,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/notes',
      queryParameters: {
        'page': page,
        'size': size,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
    );
    final data = _unwrapMap(response.data);
    return KnowledgeNotePage.fromJson(data);
  }

  Future<KnowledgeNote> getNote(String noteId) async {
    final response = await _dio.get<dynamic>('/api/v1/notes/$noteId');
    return KnowledgeNote.fromJson(_unwrapMap(response.data));
  }

  Future<KnowledgeNote> createNote({
    required String tenantId,
    required String title,
    required String contentMd,
    List<String> tags = const [],
    String? deckId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/notes',
      data: _notePayload(
        tenantId: tenantId,
        title: title,
        contentMd: contentMd,
        tags: tags,
        deckId: deckId,
      ),
    );
    return KnowledgeNote.fromJson(_unwrapMap(response.data));
  }

  Future<KnowledgeNote> updateNote({
    required String noteId,
    required String tenantId,
    required String title,
    required String contentMd,
    List<String> tags = const [],
    String? deckId,
  }) async {
    final response = await _dio.patch<dynamic>(
      '/api/v1/notes/$noteId',
      data: _notePayload(
        tenantId: tenantId,
        title: title,
        contentMd: contentMd,
        tags: tags,
        deckId: deckId,
      ),
    );
    return KnowledgeNote.fromJson(_unwrapMap(response.data));
  }

  Future<void> deleteNote(String noteId) async {
    await _dio.delete<void>('/api/v1/notes/$noteId');
  }

  Future<List<KnowledgeNote>> getBacklinks(String noteId) {
    return _getNoteList('/api/v1/notes/$noteId/backlinks');
  }

  Future<List<KnowledgeNote>> getOutlinks(String noteId) {
    return _getNoteList('/api/v1/notes/$noteId/outlinks');
  }

  Future<KnowledgeSearchPage> searchNotes({
    required String query,
    String? cursor,
    int limit = 20,
    List<String> tags = const [],
  }) async {
    if (query.trim().isEmpty) return KnowledgeSearchPage.empty();
    final response = await _dio.get<dynamic>(
      '/api/v1/notes/search',
      queryParameters: {
        'q': query,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
        if (tags.isNotEmpty) 'tags': tags,
      },
    );
    return KnowledgeSearchPage.fromJson(_unwrapMap(response.data));
  }

  Future<KnowledgeSearchPage> hybridSearch({
    required String query,
    int limit = 20,
    List<String> tags = const [],
  }) async {
    if (query.trim().isEmpty) return KnowledgeSearchPage.empty();
    final response = await _dio.post<dynamic>(
      '/api/v1/ai/search/hybrid',
      data: {'query': query, 'limit': limit, 'tags': tags},
    );
    return KnowledgeSearchPage.fromJson(_unwrapMap(response.data));
  }

  Future<List<KnowledgeTagStat>> popularTags({int limit = 20}) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/tags/popular',
      queryParameters: {'limit': limit},
    );
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(KnowledgeTagStat.fromJson)
        .where((item) => item.tag.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<KnowledgeTagStat>> autocompleteTags(String query) async {
    if (query.trim().isEmpty) return const [];
    final response = await _dio.get<dynamic>(
      '/api/v1/tags/autocomplete',
      queryParameters: {'q': query},
    );
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(KnowledgeTagStat.fromJson)
        .where((item) => item.tag.isNotEmpty)
        .toList(growable: false);
  }

  Future<KnowledgeGraphData> getGraphData() async {
    final response = await _dio.get<dynamic>('/api/v1/graph/data');
    return KnowledgeGraphData.fromJson(_unwrapMap(response.data));
  }

  Future<KnowledgeGraphData> getNeighborGraph({
    required String noteId,
    int depth = 2,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/graph',
      queryParameters: {'noteId': noteId, 'depth': depth},
    );
    return KnowledgeGraphData.fromJson(_unwrapMap(response.data));
  }

  Future<List<KnowledgeNoteVersion>> listVersions(String noteId) async {
    final response = await _dio.get<dynamic>('/api/v1/notes/$noteId/versions');
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(KnowledgeNoteVersion.fromJson)
        .toList(growable: false);
  }

  Future<KnowledgeNoteVersion> getVersion({
    required String noteId,
    required int versionNo,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/v1/notes/$noteId/versions/$versionNo',
    );
    return KnowledgeNoteVersion.fromJson(_unwrapMap(response.data));
  }

  Future<KnowledgeNote> restoreVersion({
    required String noteId,
    required int versionNo,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/notes/$noteId/versions/$versionNo/restore',
    );
    return KnowledgeNote.fromJson(_unwrapMap(response.data));
  }

  Future<List<KnowledgeNote>> _getNoteList(String path) async {
    final response = await _dio.get<dynamic>(path);
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(KnowledgeNote.fromJson)
        .toList(growable: false);
  }
}

Map<String, dynamic> _notePayload({
  required String tenantId,
  required String title,
  required String contentMd,
  required List<String> tags,
  String? deckId,
}) {
  return {
    'tenantId': tenantId,
    'title': title,
    'contentMd': contentMd,
    'tags': tags,
    if (deckId != null && deckId.isNotEmpty) 'deckId': deckId,
  };
}

Map<String, dynamic> _unwrapMap(Object? payload) {
  final unwrapped = _unwrapData(payload);
  if (unwrapped is Map<String, dynamic>) return unwrapped;
  if (unwrapped is Map) {
    return unwrapped.map((key, value) => MapEntry('$key', value));
  }
  throw const FormatException('Invalid knowledge API response.');
}

List<dynamic> _unwrapList(Object? payload) {
  final unwrapped = _unwrapData(payload);
  if (unwrapped is List) return unwrapped;
  if (unwrapped is Map<String, dynamic>) {
    return _listValue(
      unwrapped['content'] ?? unwrapped['items'] ?? unwrapped['results'],
    );
  }
  return const [];
}

Object? _unwrapData(Object? payload) {
  if (payload is Map<String, dynamic> && payload.containsKey('data')) {
    return payload['data'];
  }
  if (payload is Map && payload.containsKey('data')) {
    return payload['data'];
  }
  return payload;
}

List<dynamic> _listValue(Object? value) => value is List ? value : const [];

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
}

String _stringId(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is num) return value.toInt().toString();
  return '$value';
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _doubleValue(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

DateTime? _dateTimeValue(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String _relativeDate(DateTime? value) {
  if (value == null) return '시간 미상';
  final difference = DateTime.now().difference(value.toLocal());
  if (difference.inMinutes < 1) return '방금 전';
  if (difference.inHours < 1) return '${difference.inMinutes}분 전';
  if (difference.inDays < 1) return '${difference.inHours}시간 전';
  if (difference.inDays < 7) return '${difference.inDays}일 전';
  final local = value.toLocal();
  return '${local.month.toString().padLeft(2, '0')}/'
      '${local.day.toString().padLeft(2, '0')}';
}

int _clusterFor(String title) {
  return title.runes.fold<int>(0, (hash, code) => hash + code) % 4;
}
