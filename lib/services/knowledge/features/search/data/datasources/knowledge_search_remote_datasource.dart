import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/knowledge/features/search/data/models/hybrid_search_response_model.dart';
import 'package:synapse_frontend/services/knowledge/features/search/data/models/keyword_search_response_model.dart';

class KnowledgeSearchRemoteDatasource {
  const KnowledgeSearchRemoteDatasource(this._dio);

  final Dio _dio;

  Future<HybridSearchResponseModel> searchSemantic({
    required String query,
    int limit = 20,
    List<String> tags = const <String>[],
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '/api/v1/ai/search/hybrid',
      data: <String, dynamic>{
        'query': query,
        'limit': limit,
        'tags': tags,
      },
    );

    return HybridSearchResponseModel.fromJson(
      _unwrap(response) as Map<String, dynamic>,
    );
  }

  Future<KeywordSearchResponseModel> searchKeyword({
    required String query,
    String? cursor,
    int limit = 20,
    List<String> tags = const <String>[],
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '/api/v1/notes/search',
      queryParameters: <String, dynamic>{
        'q': query,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
        if (tags.isNotEmpty) 'tags': tags,
      },
    );

    return KeywordSearchResponseModel.fromJson(
      _unwrap(response) as Map<String, dynamic>,
    );
  }
}

Object? _unwrap(Response<Map<String, dynamic>> response) {
  return (response.data ?? const <String, dynamic>{})['data'];
}
