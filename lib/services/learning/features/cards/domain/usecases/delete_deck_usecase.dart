import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class DeleteDeckUseCase {
  const DeleteDeckUseCase(this._repository);
  final CardsRepository _repository;

  Future<void> call(String deckId) => _repository.deleteDeck(deckId);
}
