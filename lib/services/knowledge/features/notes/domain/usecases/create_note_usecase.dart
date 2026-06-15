import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';

class CreateNoteUseCase {
  const CreateNoteUseCase(this._repository);

  final KnowledgeNotesRepository _repository;

  Future<Note> call({
    required String title,
    required String contentMd,
    required List<String> tags,
  }) {
    return _repository.createNote(title: title, contentMd: contentMd, tags: tags);
  }
}
