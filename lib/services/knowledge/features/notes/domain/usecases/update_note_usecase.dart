import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';

class UpdateNoteUseCase {
  const UpdateNoteUseCase(this._repository);

  final KnowledgeNotesRepository _repository;

  Future<Note> call({
    required String noteId,
    required String title,
    required String contentMd,
    required List<String> tags,
  }) {
    return _repository.updateNote(
      noteId: noteId,
      title: title,
      contentMd: contentMd,
      tags: tags,
    );
  }
}
