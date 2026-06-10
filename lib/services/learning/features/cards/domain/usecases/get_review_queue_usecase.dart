import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class GetReviewQueueUseCase {
  const GetReviewQueueUseCase(this._repository);
  final CardsRepository _repository;

  Future<List<ReviewCard>> call(String deckId) => _repository.getReviewQueue(deckId);
}
