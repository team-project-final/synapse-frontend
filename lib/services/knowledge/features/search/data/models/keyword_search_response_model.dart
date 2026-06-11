import 'package:synapse_frontend/services/knowledge/features/search/data/models/knowledge_search_item_model.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_result.dart';

class KeywordSearchResponseModel {
  const KeywordSearchResponseModel({
    required this.items,
    required this.totalCount,
    required this.hasNext,
    this.nextCursor,
  });

  factory KeywordSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return KeywordSearchResponseModel(
      items: (json['results'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic value) => KnowledgeSearchItemModel.fromKeywordJson(value as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
    );
  }

  final List<KnowledgeSearchItemModel> items;
  final int totalCount;
  final bool hasNext;
  final String? nextCursor;

  KnowledgeSearchResult toEntity() {
    return KnowledgeSearchResult(
      items: items.map((KnowledgeSearchItemModel item) => item.toEntity()).toList(),
      totalCount: totalCount,
      hasNext: hasNext,
      nextCursor: nextCursor,
    );
  }
}
