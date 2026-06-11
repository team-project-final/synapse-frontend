import 'package:synapse_frontend/services/learning/features/cards/data/datasources/cards_remote_datasource.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/deck.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/flash_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_card.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_session.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_stats.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_submit_result.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/repositories/cards_repository.dart';

class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this._datasource);
  final CardsRemoteDatasource _datasource;

  @override
  Future<List<Deck>> listDecks({int page = 0, int size = 20}) async {
    final models = await _datasource.listDecks(page: page, size: size);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Deck> createDeck({required String name, String? description, String? color}) async {
    final model = await _datasource.createDeck(name: name, description: description, color: color);
    return model.toEntity();
  }

  @override
  Future<Deck> updateDeck(String deckId, {String? name, String? description, String? color}) async {
    final model = await _datasource.updateDeck(deckId, name: name, description: description, color: color);
    return model.toEntity();
  }

  @override
  Future<void> deleteDeck(String deckId) => _datasource.deleteDeck(deckId);

  @override
  Future<List<FlashCard>> listCards(String deckId, {int page = 0, int size = 100}) async {
    final models = await _datasource.listCards(deckId, page: page, size: size);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FlashCard> createCard(String deckId, {required String frontContent, required String backContent, required String cardType}) async {
    final model = await _datasource.createCard(deckId, frontContent: frontContent, backContent: backContent, cardType: cardType);
    return model.toEntity();
  }

  @override
  Future<List<FlashCard>> batchCreateCards(String deckId, List<Map<String, String>> cards) async {
    final models = await _datasource.batchCreateCards(deckId, cards);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FlashCard> updateCard(String deckId, String cardId, {String? frontContent, String? backContent, String? cardType}) async {
    final model = await _datasource.updateCard(deckId, cardId, frontContent: frontContent, backContent: backContent, cardType: cardType);
    return model.toEntity();
  }

  @override
  Future<void> deleteCard(String deckId, String cardId) => _datasource.deleteCard(deckId, cardId);

  @override
  Future<ReviewSession> startReviewSession(String deckId) async {
    final model = await _datasource.startReviewSession(deckId);
    return model.toEntity();
  }

  @override
  Future<List<ReviewCard>> getReviewQueue(String deckId) async {
    final models = await _datasource.getReviewQueue(deckId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ReviewSubmitResult> submitReview({required String sessionId, required String cardId, required int rating, int? timeSpentMs}) async {
    final model = await _datasource.submitReview(sessionId: sessionId, cardId: cardId, rating: rating, timeSpentMs: timeSpentMs);
    return model.toEntity();
  }

  @override
  Future<ReviewSession> completeReviewSession(String sessionId) async {
    final model = await _datasource.completeReviewSession(sessionId);
    return model.toEntity();
  }

  @override
  Future<List<FlashCard>> getSharedDeckCards(
    String deckId, {
    required String sharedContentId,
    required String shareToken,
  }) async {
    final detail = await _datasource.getSharedDeckDetail(
      deckId,
      sharedContentId: sharedContentId,
      shareToken: shareToken,
    );
    return detail.cardsToEntities();
  }

  @override
  Future<void> copyFromShare(
    String deckId, {
    required String sharedContentId,
    required String shareToken,
  }) =>
      _datasource.copyFromShare(
        deckId,
        sharedContentId: sharedContentId,
        shareToken: shareToken,
      );

  @override
  Future<ReviewStats> getStatsOverview() async {
    final model = await _datasource.getStatsOverview();
    return model.toEntity();
  }

  @override
  Future<ReviewHeatmap> getStatsHeatmap() async {
    final model = await _datasource.getStatsHeatmap();
    return model.toEntity();
  }

  @override
  Future<ReviewRetention> getStatsRetention() async {
    final model = await _datasource.getStatsRetention();
    return model.toEntity();
  }
}
