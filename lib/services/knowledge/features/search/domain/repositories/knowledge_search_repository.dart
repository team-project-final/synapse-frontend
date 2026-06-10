import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_result.dart';

abstract interface class KnowledgeSearchRepository {
  Future<KnowledgeSearchResult> searchSemantic({
    required String query,
    int limit = 20,
    List<String> tags = const <String>[],
  });

  Future<KnowledgeSearchResult> searchKeyword({
    required String query,
    String? cursor,
    int limit = 20,
    List<String> tags = const <String>[],
  });
}
