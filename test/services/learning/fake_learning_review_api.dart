import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/learning_review_api.dart';

class FakeLearningReviewApi extends LearningReviewApi {
  FakeLearningReviewApi() : super(Dio());

  static const deckId = 'e0000000-0000-0000-0000-000000000001';
  static const sessionId = 's0000000-0000-0000-0000-000000000001';

  final submittedRatings = <int>[];

  @override
  Future<LearningDeckPage> listDecks({
    required String tenantId,
    int page = 0,
    int size = 20,
  }) async {
    return const LearningDeckPage(
      items: [
        LearningDeck(
          id: deckId,
          name: 'Java & Spring 핵심 개념',
          description: '복습용 데모 덱',
        ),
      ],
      page: 0,
      size: 20,
      totalElements: 1,
      totalPages: 1,
      last: true,
    );
  }

  @override
  Future<ReviewSession> startSession({
    required String tenantId,
    required String deckId,
  }) async {
    return ReviewSession(
      id: sessionId,
      deckId: deckId,
      status: 'in_progress',
      totalCards: 2,
      reviewedCards: 0,
      startedAt: DateTime.utc(2026, 6, 22, 1),
    );
  }

  @override
  Future<List<ReviewCard>> getReviewQueue({
    required String tenantId,
    required String deckId,
  }) async {
    return [
      ReviewCard(
        id: 'c0000000-0000-0000-0000-000000000001',
        cardType: 'qa',
        frontContent: '스택이란?',
        backContent: 'LIFO 구조의 자료구조입니다.',
        bloomLevel: 'remember',
        repetitions: 1,
        easinessFactor: 2.5,
        dueDate: DateTime.utc(2026, 6, 22),
      ),
      ReviewCard(
        id: 'c0000000-0000-0000-0000-000000000002',
        cardType: 'qa',
        frontContent: '큐란?',
        backContent: 'FIFO 구조의 자료구조입니다.',
        bloomLevel: 'remember',
        repetitions: 0,
        easinessFactor: 2.5,
        dueDate: DateTime.utc(2026, 6, 22),
      ),
    ];
  }

  @override
  Future<ReviewSubmitResult> submitReview({
    required String tenantId,
    required String sessionId,
    required String cardId,
    required int rating,
    required int timeSpentMs,
  }) async {
    submittedRatings.add(rating);
    return ReviewSubmitResult(
      cardId: cardId,
      rating: rating,
      newEaseFactor: rating >= 3 ? 2.5 : 2.2,
      newIntervalDays: rating >= 3 ? 1 : 0,
      lapses: rating <= 1 ? 1 : 0,
      dueDate: DateTime.utc(2026, 6, rating >= 3 ? 23 : 22),
    );
  }

  @override
  Future<ReviewSession> completeSession({
    required String tenantId,
    required String sessionId,
  }) async {
    return ReviewSession(
      id: sessionId,
      deckId: deckId,
      status: 'completed',
      totalCards: 2,
      reviewedCards: 2,
    );
  }
}
