import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';

class DeckModel {
  const DeckModel({
    required this.id,
    required this.name,
    this.description = '',
    this.color = '',
    this.createdAt,
    this.updatedAt,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  final String id;
  final String name;
  final String description;
  final String color;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Deck toEntity() => Deck(
        id: id,
        name: name,
        description: description,
        color: color,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
