import 'package:synapse_frontend/services/knowledge/features/notes/data/datasources/knowledge_notes_remote_datasource.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/models/note_model.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/models/note_version_model.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/models/popular_tag_model.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note_version.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/popular_tag.dart';
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

  @override
  Future<List<Note>> getBacklinks(String noteId) async {
    final List<NoteModel> models = await _datasource.fetchBacklinks(noteId);
    return models.map((NoteModel model) => model.toEntity()).toList();
  }

  @override
  Future<List<Note>> getOutlinks(String noteId) async {
    final List<NoteModel> models = await _datasource.fetchOutlinks(noteId);
    return models.map((NoteModel model) => model.toEntity()).toList();
  }

  @override
  Future<Note> createNote({
    required String title,
    required String contentMd,
    required List<String> tags,
  }) async {
    final NoteModel model = await _datasource.createNote(
      title: title,
      contentMd: contentMd,
      tags: tags,
    );
    return model.toEntity();
  }

  @override
  Future<Note> updateNote({
    required String noteId,
    required String title,
    required String contentMd,
    required List<String> tags,
  }) async {
    final NoteModel model = await _datasource.updateNote(
      id: noteId,
      title: title,
      contentMd: contentMd,
      tags: tags,
    );
    return model.toEntity();
  }

  @override
  Future<List<NoteVersionSummary>> getVersions(String noteId) async {
    final List<NoteVersionSummaryModel> models =
        await _datasource.fetchVersions(noteId);
    return models.map((NoteVersionSummaryModel m) => m.toEntity()).toList();
  }

  @override
  Future<NoteVersionDetail> getVersion(String noteId, int versionNo) async {
    final NoteVersionDetailModel model =
        await _datasource.fetchVersion(noteId, versionNo);
    return model.toEntity();
  }

  @override
  Future<Note> restoreVersion(String noteId, int versionNo) async {
    final NoteModel model = await _datasource.restoreVersion(noteId, versionNo);
    return model.toEntity();
  }

  @override
  Future<List<PopularTag>> getPopularTags() async {
    final List<PopularTagModel> models = await _datasource.fetchPopularTags();
    return models.map((PopularTagModel m) => m.toEntity()).toList();
  }
}
