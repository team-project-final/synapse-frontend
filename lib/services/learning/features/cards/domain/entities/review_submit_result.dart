class ReviewSubmitResult {
  const ReviewSubmitResult({
    required this.cardId,
    required this.rating,
    required this.newEaseFactor,
    required this.newIntervalDays,
    required this.lapses,
    this.dueDate,
  });

  final String cardId;
  final int rating;
  final double newEaseFactor;
  final int newIntervalDays;
  final int lapses;
  final DateTime? dueDate;
}
