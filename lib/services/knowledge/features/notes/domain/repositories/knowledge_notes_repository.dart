import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';

abstract interface class KnowledgeNotesRepository {
  Future<List<Note>> getNotes({String? tag});

  Future<Note> getNote(String noteId);
}
