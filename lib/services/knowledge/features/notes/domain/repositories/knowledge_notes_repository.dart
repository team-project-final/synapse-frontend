import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';

abstract interface class KnowledgeNotesRepository {
  Future<List<Note>> getNotes({String? tag});

  Future<Note> getNote(String noteId);

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
