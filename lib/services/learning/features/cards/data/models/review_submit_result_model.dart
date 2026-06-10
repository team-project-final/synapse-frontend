import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_submit_result.dart';

class ReviewSubmitResultModel {
  const ReviewSubmitResultModel({
    required this.cardId,
    required this.rating,
    this.newEaseFactor = 2.5,
    this.newIntervalDays = 0,
    this.lapses = 0,
    this.dueDate,
  });

  factory ReviewSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return ReviewSubmitResultModel(
      cardId: json['cardId']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      newEaseFactor: (json['newEaseFactor'] as num?)?.toDouble() ?? 2.5,
      newIntervalDays: (json['newIntervalDays'] as num?)?.toInt() ?? 0,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      dueDate: _parseDate(json['dueDate']),
    );
  }

  final String cardId;
  final int rating;
  final double newEaseFactor;
  final int newIntervalDays;
  final int lapses;
  final DateTime? dueDate;

  ReviewSubmitResult toEntity() => ReviewSubmitResult(
        cardId: cardId,
        rating: rating,
        newEaseFactor: newEaseFactor,
        newIntervalDays: newIntervalDays,
        lapses: lapses,
        dueDate: dueDate,
      );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
