import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';

class GetNoteUseCase {
  const GetNoteUseCase(this._repository);

  final KnowledgeNotesRepository _repository;

  Future<Note> call(String noteId) {
    return _repository.getNote(noteId);
  }
}
