import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class DeleteCardUseCase {
  const DeleteCardUseCase(this._repository);
  final CardsRepository _repository;

  Future<void> call(String deckId, String cardId) =>
      _repository.deleteCard(deckId, cardId);
}
