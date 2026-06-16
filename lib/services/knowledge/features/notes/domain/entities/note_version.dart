/// 노트 버전 요약 (목록용).
class NoteVersionSummary {
  const NoteVersionSummary({
    required this.versionNo,
    required this.title,
    required this.createdAt,
  });

  final int versionNo;
  final String title;
  final DateTime createdAt;
}

/// 노트 버전 상세 (본문 포함).
class NoteVersionDetail {
  const NoteVersionDetail({
    required this.versionNo,
    required this.title,
    required this.contentMd,
    required this.createdAt,
  });

  final int versionNo;
  final String title;
  final String contentMd;
  final DateTime createdAt;
}
