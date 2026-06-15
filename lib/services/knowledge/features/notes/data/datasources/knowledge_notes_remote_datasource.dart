import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/models/note_model.dart';

class KnowledgeNotesRemoteDatasource {
  const KnowledgeNotesRemoteDatasource(this._dio);

  // 백엔드 NoteCreateRequest 는 tenantId(필수)를 요구한다. 프론트는 tenant 컨텍스트가
  // 없어 앱 기본 테넌트를 사용한다(수정 시 백엔드는 이 값을 무시하고 원본 tenant 유지).
  static const String _defaultTenantId = '00000000-0000-0000-0000-000000000001';

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

  Future<NoteModel> createNote({
    required String title,
    required String contentMd,
    required List<String> tags,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '/api/v1/notes',
      data: <String, dynamic>{
        'tenantId': _defaultTenantId,
        'title': title,
        'contentMd': contentMd,
        'tags': tags,
      },
    );

    final Map<String, dynamic> data =
        (response.data?['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return NoteModel.fromJson(data);
  }

  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String contentMd,
    required List<String> tags,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.patch<Map<String, dynamic>>(
      '/api/v1/notes/$id',
      data: <String, dynamic>{
        'tenantId': _defaultTenantId,
        'title': title,
        'contentMd': contentMd,
        'tags': tags,
      },
    );

    final Map<String, dynamic> data =
        (response.data?['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return NoteModel.fromJson(data);
  }
}
