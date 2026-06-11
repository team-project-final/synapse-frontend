import 'package:synapse_frontend/services/knowledge/features/search/data/models/knowledge_search_item_model.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_result.dart';

class HybridSearchResponseModel {
  const HybridSearchResponseModel({
    required this.items,
    required this.totalCount,
    required this.hasNext,
    this.nextCursor,
    this.searchTimeMs,
    required this.semanticFallback,
  });

  factory HybridSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return HybridSearchResponseModel(
      items: (json['results'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic value) => KnowledgeSearchItemModel.fromHybridJson(value as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
      searchTimeMs: (json['searchTimeMs'] as num?)?.toInt(),
      semanticFallback: json['semanticFallback'] as bool? ?? false,
    );
  }

  final List<KnowledgeSearchItemModel> items;
  final int totalCount;
  final bool hasNext;
  final String? nextCursor;
  final int? searchTimeMs;
  final bool semanticFallback;

  KnowledgeSearchResult toEntity() {
    return KnowledgeSearchResult(
      items: items.map((KnowledgeSearchItemModel item) => item.toEntity()).toList(),
      totalCount: totalCount,
      hasNext: hasNext,
      nextCursor: nextCursor,
      searchTimeMs: searchTimeMs,
      semanticFallback: semanticFallback,
    );
  }
}
