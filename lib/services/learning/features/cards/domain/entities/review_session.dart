class ReviewSession {
  const ReviewSession({
    required this.sessionId,
    required this.deckId,
    required this.status,
    required this.totalCards,
    required this.reviewedCards,
    this.startedAt,
    this.completedAt,
  });

  final String sessionId;
  final String deckId;
  final String status;
  final int totalCards;
  final int reviewedCards;
  final DateTime? startedAt;
  final DateTime? completedAt;
}
