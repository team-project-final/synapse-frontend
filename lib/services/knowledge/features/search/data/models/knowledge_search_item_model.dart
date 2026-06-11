import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_item.dart';

class KnowledgeSearchItemModel {
  const KnowledgeSearchItemModel({
    required this.noteId,
    required this.title,
    required this.snippet,
    required this.highlights,
    this.keywordScore,
    this.semanticScore,
    this.rrfScore,
  });

  factory KnowledgeSearchItemModel.fromHybridJson(Map<String, dynamic> json) {
    final List<String> highlights = (json['highlights'] as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic value) => value as String)
        .toList();
    final String fallbackSnippet = highlights.isNotEmpty ? highlights.first : '';

    return KnowledgeSearchItemModel(
      noteId: (json['noteId'] as num).toString(),
      title: json['title'] as String? ?? '',
      snippet: json['snippet'] as String? ?? fallbackSnippet,
      highlights: highlights,
      keywordScore: (json['keywordScore'] as num?)?.toDouble(),
      semanticScore: (json['semanticScore'] as num?)?.toDouble(),
      rrfScore: (json['rrfScore'] as num?)?.toDouble(),
    );
  }

  factory KnowledgeSearchItemModel.fromKeywordJson(Map<String, dynamic> json) {
    final List<String> highlights = (json['highlights'] as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic value) => value as String)
        .toList();

    return KnowledgeSearchItemModel(
      noteId: (json['noteId'] as num).toString(),
      title: json['title'] as String? ?? '',
      snippet: highlights.isNotEmpty ? highlights.first : '',
      highlights: highlights,
      keywordScore: (json['score'] as num?)?.toDouble(),
    );
  }

  final String noteId;
  final String title;
  final String snippet;
  final List<String> highlights;
  final double? keywordScore;
  final double? semanticScore;
  final double? rrfScore;

  KnowledgeSearchItem toEntity() {
    return KnowledgeSearchItem(
      noteId: noteId,
      title: title,
      snippet: snippet,
      highlights: highlights,
      keywordScore: keywordScore,
      semanticScore: semanticScore,
      rrfScore: rrfScore,
    );
  }
}
