import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class ListDecksUseCase {
  const ListDecksUseCase(this._repository);
  final CardsRepository _repository;

  Future<List<Deck>> call({int page = 0, int size = 20}) =>
      _repository.listDecks(page: page, size: size);
}
