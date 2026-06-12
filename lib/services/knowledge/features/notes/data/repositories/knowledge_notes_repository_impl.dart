import 'package:synapse_frontend/services/knowledge/features/notes/data/datasources/knowledge_notes_remote_datasource.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/models/note_model.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';

class KnowledgeNotesRepositoryImpl implements KnowledgeNotesRepository {
  const KnowledgeNotesRepositoryImpl(this._datasource);

  final KnowledgeNotesRemoteDatasource _datasource;

  @override
  Future<List<Note>> getNotes({String? tag}) async {
    final List<NoteModel> models = await _datasource.fetchNotes(tag: tag);
    return models.map((NoteModel model) => model.toEntity()).toList();
  }

  @override
  Future<Note> getNote(String noteId) async {
    final NoteModel model = await _datasource.fetchNote(noteId);
    return model.toEntity();
  }
}
