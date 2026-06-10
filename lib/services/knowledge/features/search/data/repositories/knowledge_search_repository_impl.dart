import 'package:synapse_frontend/services/knowledge/features/search/data/datasources/knowledge_search_remote_datasource.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_result.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/repositories/knowledge_search_repository.dart';

class KnowledgeSearchRepositoryImpl implements KnowledgeSearchRepository {
  const KnowledgeSearchRepositoryImpl(this._datasource);

  final KnowledgeSearchRemoteDatasource _datasource;

  @override
  Future<KnowledgeSearchResult> searchSemantic({
    required String query,
    int limit = 20,
    List<String> tags = const <String>[],
  }) async {
    final response = await _datasource.searchSemantic(
      query: query,
      limit: limit,
      tags: tags,
    );
    return response.toEntity();
  }

  @override
  Future<KnowledgeSearchResult> searchKeyword({
    required String query,
    String? cursor,
    int limit = 20,
    List<String> tags = const <String>[],
  }) async {
    final response = await _datasource.searchKeyword(
      query: query,
      cursor: cursor,
      limit: limit,
      tags: tags,
    );
    return response.toEntity();
  }
}
