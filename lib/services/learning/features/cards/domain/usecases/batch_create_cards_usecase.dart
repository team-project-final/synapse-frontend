import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class BatchCreateCardsUseCase {
  const BatchCreateCardsUseCase(this._repository);
  final CardsRepository _repository;

  Future<List<FlashCard>> call(String deckId, List<Map<String, String>> cards) =>
      _repository.batchCreateCards(deckId, cards);
}
