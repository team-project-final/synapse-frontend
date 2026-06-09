import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_session.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class StartReviewSessionUseCase {
  const StartReviewSessionUseCase(this._repository);
  final CardsRepository _repository;

  Future<ReviewSession> call(String deckId) => _repository.startReviewSession(deckId);
}
