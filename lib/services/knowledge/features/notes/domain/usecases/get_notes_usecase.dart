import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';

class GetNotesUseCase {
  const GetNotesUseCase(this._repository);

  final KnowledgeNotesRepository _repository;

  Future<List<Note>> call({String? tag}) {
    return _repository.getNotes(tag: tag);
  }
}
