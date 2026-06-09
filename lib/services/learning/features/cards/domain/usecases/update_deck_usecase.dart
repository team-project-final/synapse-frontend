import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class UpdateDeckUseCase {
  const UpdateDeckUseCase(this._repository);
  final CardsRepository _repository;

  Future<Deck> call(String deckId, {String? name, String? description, String? color}) =>
      _repository.updateDeck(deckId, name: name, description: description, color: color);
}
