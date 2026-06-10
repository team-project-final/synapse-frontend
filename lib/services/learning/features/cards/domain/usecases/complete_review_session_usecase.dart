import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_session.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class CompleteReviewSessionUseCase {
  const CompleteReviewSessionUseCase(this._repository);
  final CardsRepository _repository;

  Future<ReviewSession> call(String sessionId) => _repository.completeReviewSession(sessionId);
}
