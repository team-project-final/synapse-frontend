import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/models/note_model.dart';

class KnowledgeNotesRemoteDatasource {
  const KnowledgeNotesRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<NoteModel>> fetchNotes({String? tag}) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '/api/v1/notes',
      queryParameters: <String, dynamic>{
        if (tag != null && tag.isNotEmpty) 'tag': tag,
      },
    );

    // 백엔드는 ApiResponse{data: Page<NoteResponse>} 구조 → data.content 가 노트 배열.
    final Map<String, dynamic> data =
        (response.data?['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final List<dynamic> content =
        (data['content'] as List<dynamic>?) ?? const <dynamic>[];

    return content
        .map((dynamic e) => NoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NoteModel> fetchNote(String id) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>('/api/v1/notes/$id');

    final Map<String, dynamic> data =
        (response.data?['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return NoteModel.fromJson(data);
  }
}
