import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';

abstract interface class KnowledgeNotesRepository {
  Future<List<Note>> getNotes({String? tag});

  Future<Note> getNote(String noteId);

  /// 이 노트를 가리키는(들어오는) 노트 목록.
  Future<List<Note>> getBacklinks(String noteId);

  Future<Note> createNote({
    required String title,
    required String contentMd,
    required List<String> tags,
  });

  Future<Note> updateNote({
    required String noteId,
    required String title,
    required String contentMd,
    required List<String> tags,
  });
}
