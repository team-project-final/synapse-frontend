class ReviewCard {
  const ReviewCard({
    required this.cardId,
    required this.cardType,
    required this.frontContent,
    required this.backContent,
    this.bloomLevel,
    this.repetitions = 0,
    this.easinessFactor = 2.5,
    this.dueDate,
  });

  final String cardId;
  final String cardType;
  final String frontContent;
  final String backContent;
  final String? bloomLevel;
  final int repetitions;
  final double easinessFactor;
  final DateTime? dueDate;
}
