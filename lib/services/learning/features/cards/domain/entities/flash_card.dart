class FlashCard {
  const FlashCard({
    required this.id,
    required this.deckId,
    required this.cardType,
    required this.frontContent,
    required this.backContent,
    this.bloomLevel,
    this.status = 'NEW',
    this.easinessFactor = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    this.lapses = 0,
    this.dueDate,
    this.lastReviewedAt,
    this.createdAt,
  });

  final String id;
  final String deckId;
  final String cardType;
  final String frontContent;
  final String backContent;
  final String? bloomLevel;
  final String status;
  final double easinessFactor;
  final int intervalDays;
  final int repetitions;
  final int lapses;
  final DateTime? dueDate;
  final DateTime? lastReviewedAt;
  final DateTime? createdAt;
}
