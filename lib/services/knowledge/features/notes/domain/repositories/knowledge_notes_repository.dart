import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';

abstract interface class KnowledgeNotesRepository {
  Future<List<Note>> getNotes({String? tag});

  Future<Note> getNote(String noteId);

  Future<NoteShareableStatus> getShareableStatus(String noteId);

  Future<Note> getSharedDetail({
    required String noteId,
    required String sharedContentId,
    required String shareToken,
  });

  Future<Note> copyFromShare({
    required String noteId,
    required String sharedContentId,
    required String shareToken,
  });
}

class NoteShareableStatus {
  const NoteShareableStatus({
    required this.noteId,
    required this.shareable,
    required this.title,
    required this.description,
    required this.tags,
    required this.reason,
  });

  final String noteId;
  final bool shareable;
  final String title;
  final String description;
  final List<String> tags;
  final String reason;
}
