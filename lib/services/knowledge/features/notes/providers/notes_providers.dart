import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/datasources/knowledge_notes_remote_datasource.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/data/repositories/knowledge_notes_repository_impl.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/repositories/knowledge_notes_repository.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/get_note_usecase.dart';
import 'package:synapse_frontend/services/knowledge/features/notes/domain/usecases/get_notes_usecase.dart';
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

/// 노트 목록 (전체). 추후 태그 필터는 별도 family provider 로 확장.
final notesListProvider = FutureProvider.autoDispose<List<Note>>((Ref ref) {
  return ref.watch(getNotesUseCaseProvider).call();
});

/// 노트 상세 (noteId 별).
final noteDetailProvider =
    FutureProvider.autoDispose.family<Note, String>((Ref ref, String noteId) {
  return ref.watch(getNoteUseCaseProvider).call(noteId);
});
