import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class CreateCardUseCase {
  const CreateCardUseCase(this._repository);
  final CardsRepository _repository;

  Future<FlashCard> call(String deckId, {required String frontContent, required String backContent, required String cardType}) =>
      _repository.createCard(deckId, frontContent: frontContent, backContent: backContent, cardType: cardType);
}
