import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_mode.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_result.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/repositories/knowledge_search_repository.dart';

class SearchKnowledgeUseCase {
  const SearchKnowledgeUseCase(this._repository);

  final KnowledgeSearchRepository _repository;

  Future<KnowledgeSearchResult> call({
    required String query,
    required KnowledgeSearchMode mode,
    int limit = 20,
  }) {
    return switch (mode) {
      KnowledgeSearchMode.semantic => _repository.searchSemantic(
          query: query,
          limit: limit,
        ),
      KnowledgeSearchMode.keyword => _repository.searchKeyword(
          query: query,
          limit: limit,
        ),
    };
  }
}
