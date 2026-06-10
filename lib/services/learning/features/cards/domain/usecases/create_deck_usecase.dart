import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class CreateDeckUseCase {
  const CreateDeckUseCase(this._repository);
  final CardsRepository _repository;

  Future<Deck> call({required String name, String? description, String? color}) =>
      _repository.createDeck(name: name, description: description, color: color);
}
