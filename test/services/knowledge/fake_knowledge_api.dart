import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/knowledge/data/knowledge_api.dart';

class FakeKnowledgeApi extends KnowledgeApi {
  FakeKnowledgeApi() : super(Dio());

  static final notes = [
    KnowledgeNote(
      id: '1',
      title: '정규화 기법 (Regularization)',
      contentMd:
          '과적합 방지를 위한 기법들을 정리한다. 대표적으로 [[Lasso]]와 [[Ridge]] 정규화가 있다.\n\n신경망에서는 [[드롭아웃]]이 정규화 역할을 하며, 이는 [[과적합]]을 효과적으로 줄인다.',
      contentPlain: '과적합 방지를 위한 기법들을 정리한다. 대표적으로 Lasso와 Ridge 정규화가 있다.',
      tags: const ['머신러닝', '딥러닝'],
      status: 'ACTIVE',
      updatedAt: DateTime.utc(2026, 6, 21, 8),
    ),
    const KnowledgeNote(
      id: '2',
      title: '과적합',
      contentMd: '해결: ML 정규화 기법, 교차검증.',
      contentPlain: '"…해결: ML 정규화 기법, 교차검증."',
      tags: ['머신러닝'],
      status: 'ACTIVE',
    ),
    const KnowledgeNote(
      id: '3',
      title: '드롭아웃',
      contentMd: 'ML 정규화 기법의 한 종류로...',
      contentPlain: '"…ML 정규화 기법의 한 종류로…"',
      tags: ['딥러닝'],
      status: 'ACTIVE',
    ),
    const KnowledgeNote(
      id: '4',
      title: '교차검증',
      contentMd: 'ML 정규화 기법과 함께 사용...',
      contentPlain: '"…ML 정규화 기법과 함께 사용…"',
      tags: ['머신러닝'],
      status: 'ACTIVE',
    ),
    const KnowledgeNote(
      id: '5',
      title: '경사하강법',
      contentMd: '정규화 항을 손실에 더해...',
      contentPlain: '"…정규화 항을 손실에 더해…"',
      tags: ['최적화'],
      status: 'ACTIVE',
    ),
  ];

  static const tags = [
    KnowledgeTagStat(tag: '머신러닝', count: 12),
    KnowledgeTagStat(tag: '딥러닝', count: 7),
    KnowledgeTagStat(tag: '알고리즘', count: 8),
    KnowledgeTagStat(tag: 'AWS', count: 5),
  ];

  static const graph = KnowledgeGraphData(
    nodes: [
      KnowledgeGraphNode(
        id: '1',
        label: '정규화 기법',
        x: 350,
        y: 200,
        cluster: 0,
        linkCount: 6,
        pageRank: 0.85,
      ),
      KnowledgeGraphNode(
        id: '2',
        label: '드롭아웃',
        x: 200,
        y: 120,
        cluster: 0,
        linkCount: 4,
        pageRank: 0.62,
      ),
      KnowledgeGraphNode(
        id: '3',
        label: '과적합 방지',
        x: 150,
        y: 300,
        cluster: 1,
        linkCount: 5,
        pageRank: 0.78,
      ),
    ],
    edges: [
      KnowledgeGraphEdge(from: '1', to: '2', type: 'WIKI_LINK'),
      KnowledgeGraphEdge(from: '1', to: '3', type: 'WIKI_LINK'),
    ],
  );

  @override
  Future<KnowledgeNotePage> listNotes({
    String? tag,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final items = tag == null
        ? notes
        : notes.where((note) => note.tags.contains(tag)).toList();
    return KnowledgeNotePage(
      items: items,
      totalElements: items.length,
      totalPages: 1,
      page: page,
      size: size,
    );
  }

  @override
  Future<KnowledgeNote> getNote(String noteId) async {
    return notes.firstWhere(
      (note) => note.id == noteId,
      orElse: () => notes.first,
    );
  }

  @override
  Future<List<KnowledgeNote>> getBacklinks(String noteId) async {
    return notes.skip(1).take(4).toList(growable: false);
  }

  @override
  Future<List<KnowledgeNote>> getOutlinks(String noteId) async {
    return notes.skip(1).take(2).toList(growable: false);
  }

  @override
  Future<KnowledgeSearchPage> searchNotes({
    required String query,
    String? cursor,
    int limit = 20,
    List<String> tags = const [],
  }) async {
    if (query.trim().isEmpty) return KnowledgeSearchPage.empty();
    return KnowledgeSearchPage(
      results: [
        KnowledgeSearchResult(
          noteId: '1',
          title: query.contains('어텐') ? '어텐션 메커니즘' : notes.first.title,
          snippet: notes.first.snippet,
          highlights: const ['정규화는 과적합을 줄입니다.'],
          score: 0.92,
        ),
      ],
      totalCount: 1,
      hasNext: false,
    );
  }

  @override
  Future<KnowledgeSearchPage> hybridSearch({
    required String query,
    int limit = 20,
    List<String> tags = const [],
  }) async {
    final page = await searchNotes(query: query, limit: limit, tags: tags);
    return KnowledgeSearchPage(
      results: page.results,
      totalCount: page.totalCount,
      hasNext: false,
      searchTimeMs: 12,
    );
  }

  @override
  Future<List<KnowledgeTagStat>> popularTags({int limit = 20}) async => tags;

  @override
  Future<List<KnowledgeTagStat>> autocompleteTags(String query) async => tags;

  @override
  Future<KnowledgeGraphData> getGraphData() async => graph;

  @override
  Future<KnowledgeGraphData> getNeighborGraph({
    required String noteId,
    int depth = 2,
  }) async {
    return graph;
  }

  @override
  Future<List<KnowledgeNoteVersion>> listVersions(String noteId) async {
    return [
      KnowledgeNoteVersion(
        id: 'v3',
        versionNo: 3,
        title: 'L2 정규화 설명 추가',
        createdAt: DateTime.utc(2026, 6, 21, 9),
      ),
      KnowledgeNoteVersion(
        id: 'v2',
        versionNo: 2,
        title: '예시 코드 수정',
        createdAt: DateTime.utc(2026, 6, 20, 9),
      ),
    ];
  }

  @override
  Future<KnowledgeNoteVersion> getVersion({
    required String noteId,
    required int versionNo,
  }) async {
    return KnowledgeNoteVersion(
      id: 'v$versionNo',
      versionNo: versionNo,
      title: '버전 $versionNo',
      contentMd: '# 버전 $versionNo\n\n본문',
      createdAt: DateTime.utc(2026, 6, 21, 9),
    );
  }
}
