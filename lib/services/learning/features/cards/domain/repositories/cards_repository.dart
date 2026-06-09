import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_session.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_submit_result.dart';

abstract interface class CardsRepository {
  Future<List<Deck>> listDecks({int page = 0, int size = 20});
  Future<Deck> createDeck({required String name, String? description, String? color});
  Future<Deck> updateDeck(String deckId, {String? name, String? description, String? color});
  Future<void> deleteDeck(String deckId);

  Future<List<FlashCard>> listCards(String deckId, {int page = 0, int size = 100});
  Future<FlashCard> createCard(String deckId, {required String frontContent, required String backContent, required String cardType});
  Future<List<FlashCard>> batchCreateCards(String deckId, List<Map<String, String>> cards);
  Future<FlashCard> updateCard(String deckId, String cardId, {String? frontContent, String? backContent, String? cardType});
  Future<void> deleteCard(String deckId, String cardId);

  Future<ReviewSession> startReviewSession(String deckId);
  Future<List<ReviewCard>> getReviewQueue(String deckId);
  Future<ReviewSubmitResult> submitReview({required String sessionId, required String cardId, required int rating, int? timeSpentMs});
  Future<ReviewSession> completeReviewSession(String sessionId);
}
