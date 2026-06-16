import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/datasources/knowledge_notes_remote_datasource.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/repositories/knowledge_notes_repository_impl.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note_version.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/popular_tag.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/get_backlinks_usecase.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/get_note_usecase.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/get_popular_tags_usecase.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/note_version_usecases.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/update_note_usecase.dart';

final _knowledgeNotesRemoteDatasourceProvider =
    Provider<KnowledgeNotesRemoteDatasource>((Ref ref) {
  return KnowledgeNotesRemoteDatasource(ref.watch(dioProvider));
});

final _knowledgeNotesRepositoryProvider =
    Provider<KnowledgeNotesRepository>((Ref ref) {
  return KnowledgeNotesRepositoryImpl(
    ref.watch(_knowledgeNotesRemoteDatasourceProvider),
  );
});

final getNotesUseCaseProvider = Provider<GetNotesUseCase>((Ref ref) {
  return GetNotesUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

final getNoteUseCaseProvider = Provider<GetNoteUseCase>((Ref ref) {
  return GetNoteUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((Ref ref) {
  return CreateNoteUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>((Ref ref) {
  return UpdateNoteUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

final getBacklinksUseCaseProvider = Provider<GetBacklinksUseCase>((Ref ref) {
  return GetBacklinksUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

final getPopularTagsUseCaseProvider = Provider<GetPopularTagsUseCase>((Ref ref) {
  return GetPopularTagsUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

final getNoteVersionsUseCaseProvider = Provider<GetNoteVersionsUseCase>((Ref ref) {
  return GetNoteVersionsUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

final getNoteVersionUseCaseProvider = Provider<GetNoteVersionUseCase>((Ref ref) {
  return GetNoteVersionUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

final restoreNoteVersionUseCaseProvider =
    Provider<RestoreNoteVersionUseCase>((Ref ref) {
  return RestoreNoteVersionUseCase(ref.watch(_knowledgeNotesRepositoryProvider));
});

/// 노트 목록 — 태그 필터(null/빈 문자열이면 전체). 서버 `GET /notes?tag=` 연동.
final notesListProvider =
    FutureProvider.autoDispose.family<List<Note>, String?>((Ref ref, String? tag) {
  return ref.watch(getNotesUseCaseProvider).call(tag: tag);
});

/// 인기 태그 — 목록 필터칩용.
final popularTagsProvider = FutureProvider.autoDispose<List<PopularTag>>((Ref ref) {
  return ref.watch(getPopularTagsUseCaseProvider).call();
});

/// 노트 상세 (noteId 별).
final noteDetailProvider =
    FutureProvider.autoDispose.family<Note, String>((Ref ref, String noteId) {
  return ref.watch(getNoteUseCaseProvider).call(noteId);
});

/// 백링크 — 이 노트를 가리키는 노트 목록 (noteId 별).
final backlinksProvider =
    FutureProvider.autoDispose.family<List<Note>, String>((Ref ref, String noteId) {
  return ref.watch(getBacklinksUseCaseProvider).call(noteId);
});

/// 노트 버전 목록 (noteId 별).
final noteVersionsProvider =
    FutureProvider.autoDispose.family<List<NoteVersionSummary>, String>(
        (Ref ref, String noteId) {
  return ref.watch(getNoteVersionsUseCaseProvider).call(noteId);
});

/// 특정 버전 상세 — (noteId, versionNo) 별.
final noteVersionDetailProvider = FutureProvider.autoDispose
    .family<NoteVersionDetail, (String, int)>((Ref ref, (String, int) key) {
  return ref.watch(getNoteVersionUseCaseProvider).call(key.$1, key.$2);
});
