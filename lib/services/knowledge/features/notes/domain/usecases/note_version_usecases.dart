import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note_version.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';

class GetNoteVersionsUseCase {
  const GetNoteVersionsUseCase(this._repository);

  final KnowledgeNotesRepository _repository;

  Future<List<NoteVersionSummary>> call(String noteId) {
    return _repository.getVersions(noteId);
  }
}

class GetNoteVersionUseCase {
  const GetNoteVersionUseCase(this._repository);

  final KnowledgeNotesRepository _repository;

  Future<NoteVersionDetail> call(String noteId, int versionNo) {
    return _repository.getVersion(noteId, versionNo);
  }
}

class RestoreNoteVersionUseCase {
  const RestoreNoteVersionUseCase(this._repository);

  final KnowledgeNotesRepository _repository;

  Future<Note> call(String noteId, int versionNo) {
    return _repository.restoreVersion(noteId, versionNo);
  }
}
