import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_session.dart';

class ReviewSessionModel {
  const ReviewSessionModel({
    required this.sessionId,
    required this.deckId,
    required this.status,
    this.totalCards = 0,
    this.reviewedCards = 0,
    this.startedAt,
    this.completedAt,
  });

  factory ReviewSessionModel.fromJson(Map<String, dynamic> json) {
    return ReviewSessionModel(
      sessionId: json['sessionId']?.toString() ?? json['id']?.toString() ?? '',
      deckId: json['deckId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
      reviewedCards: (json['reviewedCards'] as num?)?.toInt() ?? 0,
      startedAt: _parseDate(json['startedAt']),
      completedAt: _parseDate(json['completedAt']),
    );
  }

  final String sessionId;
  final String deckId;
  final String status;
  final int totalCards;
  final int reviewedCards;
  final DateTime? startedAt;
  final DateTime? completedAt;

  ReviewSession toEntity() => ReviewSession(
        sessionId: sessionId,
        deckId: deckId,
        status: status,
        totalCards: totalCards,
        reviewedCards: reviewedCards,
        startedAt: startedAt,
        completedAt: completedAt,
      );
}

DateTime? _parseDate(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
