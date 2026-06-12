import 'package:dio/dio.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/models/deck_model.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/models/flash_card_model.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/models/review_card_model.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/models/review_session_model.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/models/review_submit_result_model.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/models/review_stats_model.dart';
import 'package:synapse_frontend/services/learning/features/cards/data/models/shared_deck_detail_model.dart';

class CardsRemoteDatasource {
  const CardsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<DeckModel>> listDecks({int page = 0, int size = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/decks',
      queryParameters: {'page': page, 'size': size},
    );
    final data = _unwrap(response) as Map<String, dynamic>;
    return (data['content'] as List).map((e) => DeckModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DeckModel> createDeck({required String name, String? description, String? color}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/decks',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
      },
    );
    return DeckModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<DeckModel> updateDeck(String deckId, {String? name, String? description, String? color}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/decks/$deckId',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
      },
    );
    return DeckModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<void> deleteDeck(String deckId) async {
    await _dio.delete<void>('/decks/$deckId');
  }

  Future<List<FlashCardModel>> listCards(String deckId, {int page = 0, int size = 100}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/decks/$deckId/cards',
      queryParameters: {'page': page, 'size': size},
    );
    final data = _unwrap(response) as Map<String, dynamic>;
    return (data['content'] as List).map((e) => FlashCardModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FlashCardModel> createCard(String deckId, {required String frontContent, required String backContent, required String cardType}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/decks/$deckId/cards',
      data: {'frontContent': frontContent, 'backContent': backContent, 'cardType': cardType},
    );
    return FlashCardModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<List<FlashCardModel>> batchCreateCards(String deckId, List<Map<String, String>> cards) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/decks/$deckId/cards/batch',
      data: {'cards': cards},
    );
    final data = _unwrap(response);
    return (data as List).map((e) => FlashCardModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FlashCardModel> updateCard(String deckId, String cardId, {String? frontContent, String? backContent, String? cardType}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/decks/$deckId/cards/$cardId',
      data: {
        if (frontContent != null) 'frontContent': frontContent,
        if (backContent != null) 'backContent': backContent,
        if (cardType != null) 'cardType': cardType,
      },
    );
    return FlashCardModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<void> deleteCard(String deckId, String cardId) async {
    await _dio.delete<void>('/decks/$deckId/cards/$cardId');
  }

  Future<ReviewSessionModel> startReviewSession(String deckId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/reviews/sessions',
      data: {'deckId': deckId},
    );
    return ReviewSessionModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<List<ReviewCardModel>> getReviewQueue(String deckId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reviews/queue',
      queryParameters: {'deckId': deckId},
    );
    final data = _unwrap(response);
    return (data as List).map((e) => ReviewCardModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ReviewSubmitResultModel> submitReview({required String sessionId, required String cardId, required int rating, int? timeSpentMs}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/reviews/sessions/$sessionId/submit',
      data: {
        'cardId': cardId,
        'rating': rating,
        if (timeSpentMs != null) 'timeSpentMs': timeSpentMs,
      },
    );
    return ReviewSubmitResultModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<ReviewSessionModel> completeReviewSession(String sessionId) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/reviews/sessions/$sessionId/complete',
    );
    return ReviewSessionModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<ReviewStatsModel> getStatsOverview() async {
    final response = await _dio.get<Map<String, dynamic>>('/stats/overview');
    return ReviewStatsModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<ReviewHeatmapModel> getStatsHeatmap() async {
    final response = await _dio.get<Map<String, dynamic>>('/stats/heatmap');
    return ReviewHeatmapModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<ReviewRetentionModel> getStatsRetention() async {
    final response = await _dio.get<Map<String, dynamic>>('/stats/retention');
    return ReviewRetentionModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<SharedDeckDetailModel> getSharedDeckDetail(
    String deckId, {
    required String sharedContentId,
    required String shareToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/decks/$deckId/shared-detail',
      queryParameters: {'sharedContentId': sharedContentId, 'shareToken': shareToken},
    );
    return SharedDeckDetailModel.fromJson(_unwrap(response) as Map<String, dynamic>);
  }

  Future<void> copyFromShare(
    String deckId, {
    required String sharedContentId,
    required String shareToken,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/decks/$deckId/copy-from-share',
      data: {'sharedContentId': sharedContentId, 'shareToken': shareToken},
    );
  }
}

Object? _unwrap(Response<Map<String, dynamic>> response) {
  return (response.data ?? const <String, dynamic>{})['data'];
}
