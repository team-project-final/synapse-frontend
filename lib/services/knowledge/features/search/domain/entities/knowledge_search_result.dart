import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_item.dart';

class KnowledgeSearchResult {
  const KnowledgeSearchResult({
    required this.items,
    required this.totalCount,
    required this.hasNext,
    this.nextCursor,
    this.searchTimeMs,
    this.semanticFallback = false,
  });

  const KnowledgeSearchResult.empty()
      : items = const <KnowledgeSearchItem>[],
        totalCount = 0,
        hasNext = false,
        nextCursor = null,
        searchTimeMs = null,
        semanticFallback = false;

  final List<KnowledgeSearchItem> items;
  final int totalCount;
  final bool hasNext;
  final String? nextCursor;
  final int? searchTimeMs;
  final bool semanticFallback;
}
