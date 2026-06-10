class Deck {
  const Deck({
    required this.id,
    required this.name,
    this.description = '',
    this.color = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  // color 필드에 이모지를 저장 (DeckCreateScreen에서 이모지 선택 → color로 전송)
  final String color;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get emoji => color.isNotEmpty ? color : '📚';
}
