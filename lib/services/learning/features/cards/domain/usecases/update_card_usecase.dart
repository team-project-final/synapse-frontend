import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class UpdateCardUseCase {
  const UpdateCardUseCase(this._repository);
  final CardsRepository _repository;

  Future<FlashCard> call(String deckId, String cardId, {String? frontContent, String? backContent, String? cardType}) =>
      _repository.updateCard(deckId, cardId, frontContent: frontContent, backContent: backContent, cardType: cardType);
}
