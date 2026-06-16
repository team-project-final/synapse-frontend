import 'package:synapse_frontend/services/knowledge/features/notes/domain/entities/popular_tag.dart';

class PopularTagModel {
  const PopularTagModel({required this.tag, required this.count});

  factory PopularTagModel.fromJson(Map<String, dynamic> json) {
    return PopularTagModel(
      tag: json['tag'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  final String tag;
  final int count;

  PopularTag toEntity() => PopularTag(tag: tag, count: count);
}
