import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note_version.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/popular_tag.dart';

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

  /// 노트 버전 목록.
  Future<List<NoteVersionSummary>> getVersions(String noteId);

  /// 특정 버전 상세(본문 포함).
  Future<NoteVersionDetail> getVersion(String noteId, int versionNo);

  /// 특정 버전으로 복원 → 갱신된 노트.
  Future<Note> restoreVersion(String noteId, int versionNo);

  /// 인기 태그 목록 (목록 필터칩용).
  Future<List<PopularTag>> getPopularTags();
}
