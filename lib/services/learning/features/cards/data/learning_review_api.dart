import 'package:dio/dio.dart';

class LearningDeck {
  const LearningDeck({
    required this.id,
    required this.name,
    required this.description,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  factory LearningDeck.fromJson(Map<String, dynamic> json) {
    return LearningDeck(
      id: _stringId(json['id']),
      name: (json['name'] as String?) ?? '제목 없는 덱',
      description: (json['description'] as String?) ?? '',
      color: json['color'] as String?,
      createdAt: _dateTimeValue(json['createdAt']),
      updatedAt: _dateTimeValue(json['updatedAt']),
    );
  }

  final String id;
  final String name;
  final String description;
  final String? color;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class LearningDeckPage {
  const LearningDeckPage({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory LearningDeckPage.fromJson(Map<String, dynamic> json) {
    final items = _listValue(json['content'] ?? json['items'] ?? json['data'])
        .whereType<Map<String, dynamic>>()
        .map(LearningDeck.fromJson)
        .toList(growable: false);
    return LearningDeckPage(
      items: items,
      page: _intValue(json['page']) ?? 0,
      size: _intValue(json['size']) ?? items.length,
      totalElements: _intValue(json['totalElements']) ?? items.length,
      totalPages: _intValue(json['totalPages']) ?? 1,
      last: json['last'] == true,
    );
  }

  final List<LearningDeck> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;
}

class ReviewCard {
  const ReviewCard({
    required this.id,
    required this.cardType,
    required this.frontContent,
    required this.backContent,
    required this.bloomLevel,
    required this.repetitions,
    required this.easinessFactor,
    this.dueDate,
  });

  factory ReviewCard.fromJson(Map<String, dynamic> json) {
    return ReviewCard(
      id: _stringId(json['cardId'] ?? json['id']),
      cardType: (json['cardType'] as String?) ?? 'qa',
      frontContent: (json['frontContent'] as String?) ?? '',
      backContent: (json['backContent'] as String?) ?? '',
      bloomLevel: (json['bloomLevel'] as String?) ?? '',
      repetitions: _intValue(json['repetitions']) ?? 0,
      easinessFactor: _doubleValue(json['easinessFactor']),
      dueDate: _dateTimeValue(json['dueDate']),
    );
  }

  final String id;
  final String cardType;
  final String frontContent;
  final String backContent;
  final String bloomLevel;
  final int repetitions;
  final double easinessFactor;
  final DateTime? dueDate;

  String get typeLabel => cardType.toUpperCase();
}

class ReviewSession {
  const ReviewSession({
    required this.id,
    required this.deckId,
    required this.status,
    required this.totalCards,
    required this.reviewedCards,
    this.startedAt,
    this.completedAt,
  });

  factory ReviewSession.fromJson(Map<String, dynamic> json) {
    return ReviewSession(
      id: _stringId(json['sessionId'] ?? json['id']),
      deckId: _stringId(json['deckId']),
      status: (json['status'] as String?) ?? 'unknown',
      totalCards: _intValue(json['totalCards']) ?? 0,
      reviewedCards: _intValue(json['reviewedCards']) ?? 0,
      startedAt: _dateTimeValue(json['startedAt']),
      completedAt: _dateTimeValue(json['completedAt']),
    );
  }

  final String id;
  final String deckId;
  final String status;
  final int totalCards;
  final int reviewedCards;
  final DateTime? startedAt;
  final DateTime? completedAt;
}

class ReviewSubmitResult {
  const ReviewSubmitResult({
    required this.cardId,
    required this.rating,
    required this.newEaseFactor,
    required this.newIntervalDays,
    required this.lapses,
    this.dueDate,
  });

  factory ReviewSubmitResult.fromJson(Map<String, dynamic> json) {
    return ReviewSubmitResult(
      cardId: _stringId(json['cardId']),
      rating: _intValue(json['rating']) ?? 0,
      newEaseFactor: _doubleValue(json['newEaseFactor']),
      newIntervalDays: _intValue(json['newIntervalDays']) ?? 0,
      lapses: _intValue(json['lapses']) ?? 0,
      dueDate: _dateTimeValue(json['dueDate']),
    );
  }

  final String cardId;
  final int rating;
  final double newEaseFactor;
  final int newIntervalDays;
  final int lapses;
  final DateTime? dueDate;

  bool get isRemembered => rating >= 3;
}

class LearningReviewApi {
  const LearningReviewApi(this._dio);

  final Dio _dio;

  Future<LearningDeckPage> listDecks({
    required String tenantId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<dynamic>(
      '/decks',
      queryParameters: {'page': page, 'size': size},
      options: _tenantOptions(tenantId),
    );
    return LearningDeckPage.fromJson(_unwrapMap(response.data));
  }

  Future<List<ReviewCard>> getReviewQueue({
    required String tenantId,
    required String deckId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/reviews/queue',
      queryParameters: {'deckId': deckId},
      options: _tenantOptions(tenantId),
    );
    return _unwrapList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(ReviewCard.fromJson)
        .toList(growable: false);
  }

  Future<ReviewSession> startSession({
    required String tenantId,
    required String deckId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/reviews/sessions',
      data: {'deckId': deckId},
      options: _tenantOptions(tenantId),
    );
    return ReviewSession.fromJson(_unwrapMap(response.data));
  }

  Future<ReviewSubmitResult> submitReview({
    required String tenantId,
    required String sessionId,
    required String cardId,
    required int rating,
    required int timeSpentMs,
  }) async {
    final response = await _dio.post<dynamic>(
      '/reviews/sessions/$sessionId/submit',
      data: {'cardId': cardId, 'rating': rating, 'timeSpentMs': timeSpentMs},
      options: _tenantOptions(tenantId),
    );
    return ReviewSubmitResult.fromJson(_unwrapMap(response.data));
  }

  Future<ReviewSession> completeSession({
    required String tenantId,
    required String sessionId,
  }) async {
    final response = await _dio.put<dynamic>(
      '/reviews/sessions/$sessionId/complete',
      options: _tenantOptions(tenantId),
    );
    return ReviewSession.fromJson(_unwrapMap(response.data));
  }
}

Options _tenantOptions(String tenantId) {
  return Options(headers: {'X-Tenant-Id': tenantId});
}

Map<String, dynamic> _unwrapMap(Object? payload) {
  final unwrapped = _unwrapData(payload);
  if (unwrapped is Map<String, dynamic>) return unwrapped;
  if (unwrapped is Map) {
    return unwrapped.map((key, value) => MapEntry('$key', value));
  }
  throw const FormatException('Invalid learning review API response.');
}

List<dynamic> _unwrapList(Object? payload) {
  final unwrapped = _unwrapData(payload);
  if (unwrapped is List) return unwrapped;
  if (unwrapped is Map<String, dynamic>) {
    return _listValue(
      unwrapped['content'] ?? unwrapped['items'] ?? unwrapped['results'],
    );
  }
  return const [];
}

Object? _unwrapData(Object? payload) {
  if (payload is Map<String, dynamic> && payload.containsKey('data')) {
    return payload['data'];
  }
  if (payload is Map && payload.containsKey('data')) {
    return payload['data'];
  }
  return payload;
}

List<dynamic> _listValue(Object? value) => value is List ? value : const [];

String _stringId(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is num) return value.toInt().toString();
  return '$value';
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _doubleValue(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

DateTime? _dateTimeValue(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
