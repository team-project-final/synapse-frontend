import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';

class FlashCardModel {
  const FlashCardModel({
    required this.id,
    required this.deckId,
    required this.cardType,
    required this.frontContent,
    required this.backContent,
    this.bloomLevel = '',
    this.status = 'NEW',
    this.easinessFactor = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    this.lapses = 0,
    this.dueDate,
    this.lastReviewedAt,
    this.createdAt,
  });

  factory FlashCardModel.fromJson(Map<String, dynamic> json) {
    return FlashCardModel(
      id: json['id']?.toString() ?? '',
      deckId: json['deckId']?.toString() ?? '',
      cardType: json['cardType']?.toString() ?? 'BASIC',
      frontContent: json['frontContent']?.toString() ?? '',
      backContent: json['backContent']?.toString() ?? '',
      bloomLevel: json['bloomLevel']?.toString() ?? '',
      status: json['status']?.toString() ?? 'NEW',
      easinessFactor: (json['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      dueDate: _parseDate(json['dueDate']),
      lastReviewedAt: _parseDate(json['lastReviewedAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  final String id;
  final String deckId;
  final String cardType;
  final String frontContent;
  final String backContent;
  final String bloomLevel;
  final String status;
  final double easinessFactor;
  final int intervalDays;
  final int repetitions;
  final int lapses;
  final DateTime? dueDate;
  final DateTime? lastReviewedAt;
  final DateTime? createdAt;

  FlashCard toEntity() => FlashCard(
        id: id,
        deckId: deckId,
        cardType: cardType,
        frontContent: frontContent,
        backContent: backContent,
        bloomLevel: bloomLevel,
        status: status,
        easinessFactor: easinessFactor,
        intervalDays: intervalDays,
        repetitions: repetitions,
        lapses: lapses,
        dueDate: dueDate,
        lastReviewedAt: lastReviewedAt,
        createdAt: createdAt,
      );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
