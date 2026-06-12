import 'package:synapse_frontend/services/learning/features/cards/data/models/deck_model.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/models/flash_card_model.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';

class SharedDeckDetailModel {
  const SharedDeckDetailModel({required this.deck, required this.cards});

  factory SharedDeckDetailModel.fromJson(Map<String, dynamic> json) {
    final deckJson = json['deck'] as Map<String, dynamic>? ?? {};
    final cardsJson = json['cards'] as List<dynamic>? ?? [];
    return SharedDeckDetailModel(
      deck: DeckModel.fromJson(deckJson),
      cards: cardsJson
          .map((e) => FlashCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final DeckModel deck;
  final List<FlashCardModel> cards;

  Deck deckToEntity() => deck.toEntity();
  List<FlashCard> cardsToEntities() => cards.map((c) => c.toEntity()).toList();
}
