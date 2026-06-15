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

  Future<NoteShareableStatusModel> fetchShareableStatus(String id) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>('/api/v1/notes/$id/shareable');

    final Map<String, dynamic> data =
        (response.data?['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return NoteShareableStatusModel.fromJson(data);
  }

  Future<NoteModel> fetchSharedDetail({
    required String noteId,
    required String sharedContentId,
    required String shareToken,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '/api/v1/notes/$noteId/shared-detail',
      queryParameters: <String, dynamic>{
        'sharedContentId': sharedContentId,
        'shareToken': shareToken,
      },
    );

    final Map<String, dynamic> data =
        (response.data?['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return NoteModel.fromJson(data);
  }

  Future<NoteModel> copyFromShare({
    required String noteId,
    required String sharedContentId,
    required String shareToken,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '/api/v1/notes/$noteId/copy-from-share',
      data: <String, dynamic>{
        'sharedContentId': sharedContentId,
        'shareToken': shareToken,
      },
    );

    final Map<String, dynamic> data =
        (response.data?['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return NoteModel.fromJson(data);
  }
}

class NoteShareableStatusModel {
  const NoteShareableStatusModel({
    required this.noteId,
    required this.shareable,
    required this.title,
    required this.description,
    required this.tags,
    required this.reason,
  });

  factory NoteShareableStatusModel.fromJson(Map<String, dynamic> json) {
    final List<String> tags = (json['tags'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<String>()
        .toList(growable: false);

    return NoteShareableStatusModel(
      noteId: '${json['noteId'] ?? ''}',
      shareable: (json['shareable'] as bool?) ?? false,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      tags: tags,
      reason: (json['reason'] ?? '').toString(),
    );
  }

  final String noteId;
  final bool shareable;
  final String title;
  final String description;
  final List<String> tags;
  final String reason;
}
