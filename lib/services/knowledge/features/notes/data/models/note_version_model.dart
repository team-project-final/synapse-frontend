import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note_version.dart';

class NoteVersionSummaryModel {
  const NoteVersionSummaryModel({
    required this.versionNo,
    required this.title,
    required this.createdAt,
  });

  factory NoteVersionSummaryModel.fromJson(Map<String, dynamic> json) {
    return NoteVersionSummaryModel(
      versionNo: (json['versionNo'] as num).toInt(),
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int versionNo;
  final String title;
  final DateTime createdAt;

  NoteVersionSummary toEntity() {
    return NoteVersionSummary(versionNo: versionNo, title: title, createdAt: createdAt);
  }
}

class NoteVersionDetailModel {
  const NoteVersionDetailModel({
    required this.versionNo,
    required this.title,
    required this.contentMd,
    required this.createdAt,
  });

  factory NoteVersionDetailModel.fromJson(Map<String, dynamic> json) {
    return NoteVersionDetailModel(
      versionNo: (json['versionNo'] as num).toInt(),
      title: json['title'] as String? ?? '',
      contentMd: json['contentMd'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int versionNo;
  final String title;
  final String contentMd;
  final DateTime createdAt;

  NoteVersionDetail toEntity() {
    return NoteVersionDetail(
      versionNo: versionNo,
      title: title,
      contentMd: contentMd,
      createdAt: createdAt,
    );
  }
}
