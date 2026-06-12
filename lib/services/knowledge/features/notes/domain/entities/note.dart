/// 노트 도메인 엔티티. 백엔드 NoteResponse 와 1:1 대응한다.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.contentMd,
    required this.contentPlain,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String contentMd;
  final String contentPlain;
  final List<String> tags;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
