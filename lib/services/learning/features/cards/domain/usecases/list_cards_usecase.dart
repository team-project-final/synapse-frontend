import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class ListCardsUseCase {
  const ListCardsUseCase(this._repository);
  final CardsRepository _repository;

  Future<List<FlashCard>> call(String deckId, {int page = 0, int size = 100}) =>
      _repository.listCards(deckId, page: page, size: size);
}
