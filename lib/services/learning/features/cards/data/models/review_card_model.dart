import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_card.dart';

class ReviewCardModel {
  const ReviewCardModel({
    required this.cardId,
    required this.cardType,
    required this.frontContent,
    required this.backContent,
    this.bloomLevel = '',
    this.repetitions = 0,
    this.easinessFactor = 2.5,
    this.dueDate,
  });

  factory ReviewCardModel.fromJson(Map<String, dynamic> json) {
    return ReviewCardModel(
      cardId: json['cardId']?.toString() ?? json['id']?.toString() ?? '',
      cardType: json['cardType']?.toString() ?? 'BASIC',
      frontContent: json['frontContent']?.toString() ?? '',
      backContent: json['backContent']?.toString() ?? '',
      bloomLevel: json['bloomLevel']?.toString() ?? '',
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      easinessFactor: (json['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      dueDate: _parseDate(json['dueDate']),
    );
  }

  final String cardId;
  final String cardType;
  final String frontContent;
  final String backContent;
  final String bloomLevel;
  final int repetitions;
  final double easinessFactor;
  final DateTime? dueDate;

  ReviewCard toEntity() => ReviewCard(
        cardId: cardId,
        cardType: cardType,
        frontContent: frontContent,
        backContent: backContent,
        bloomLevel: bloomLevel,
        repetitions: repetitions,
        easinessFactor: easinessFactor,
        dueDate: dueDate,
      );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
