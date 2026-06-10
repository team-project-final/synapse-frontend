import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_submit_result.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class SubmitReviewUseCase {
  const SubmitReviewUseCase(this._repository);
  final CardsRepository _repository;

  Future<ReviewSubmitResult> call({required String sessionId, required String cardId, required int rating, int? timeSpentMs}) =>
      _repository.submitReview(sessionId: sessionId, cardId: cardId, rating: rating, timeSpentMs: timeSpentMs);
}
