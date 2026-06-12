import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/note.dart';

class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.contentMd,
    required this.contentPlain,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final List<String> tags = (json['tags'] as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic value) => value as String)
        .toList();

    return NoteModel(
      id: (json['id'] as num).toString(),
      title: json['title'] as String? ?? '',
      contentMd: json['contentMd'] as String? ?? '',
      contentPlain: json['contentPlain'] as String? ?? '',
      tags: tags,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String title;
  final String contentMd;
  final String contentPlain;
  final List<String> tags;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note toEntity() {
    return Note(
      id: id,
      title: title,
      contentMd: contentMd,
      contentPlain: contentPlain,
      tags: tags,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
