import 'package:dio/dio.dart';

class ForecastDay {
  const ForecastDay({required this.date, required this.dueCount});

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: _dateValue(json['date']) ?? DateTime.now(),
      dueCount: _intValue(json['dueCount']) ?? 0,
    );
  }

  final DateTime date;
  final int dueCount;
}

class ReviewForecast {
  const ReviewForecast({required this.overdueCount, required this.days});

  factory ReviewForecast.fromJson(Map<String, dynamic> json) {
    return ReviewForecast(
      overdueCount: _intValue(json['overdueCount']) ?? 0,
      days: _listValue(json['days'])
          .whereType<Map<String, dynamic>>()
          .map(ForecastDay.fromJson)
          .toList(growable: false),
    );
  }

  final int overdueCount;
  final List<ForecastDay> days;

  /// 부하 정규화의 분모. 빈 목록이면 0.
  int get maxDueCount {
    var max = 0;
    for (final day in days) {
      if (day.dueCount > max) max = day.dueCount;
    }
    return max;
  }

  int dueCountOn(DateTime date) {
    for (final day in days) {
      if (_isSameDate(day.date, date)) return day.dueCount;
    }
    return 0;
  }
}

class DeckSummary {
  const DeckSummary({
    required this.deckId,
    required this.name,
    required this.totalCards,
    required this.unreviewedCards,
    required this.dueCount,
    required this.reviewedCount,
  });

  factory DeckSummary.fromJson(Map<String, dynamic> json) {
    return DeckSummary(
      deckId: (json['deckId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '이름 없는 덱',
      totalCards: _intValue(json['totalCards']) ?? 0,
      unreviewedCards: _intValue(json['unreviewedCards']) ?? 0,
      dueCount: _intValue(json['dueCount']) ?? 0,
      reviewedCount: _intValue(json['reviewedCount']) ?? 0,
    );
  }

  final String deckId;
  final String name;
  final int totalCards;
  final int unreviewedCards;
  final int dueCount;
  final int reviewedCount;
}

class DailyReviewStat {
  const DailyReviewStat({
    required this.date,
    required this.reviewCount,
    required this.correctRate,
  });

  factory DailyReviewStat.fromJson(Map<String, dynamic> json) {
    return DailyReviewStat(
      date: _dateValue(json['date']) ?? DateTime.now(),
      reviewCount: _intValue(json['reviewCount']) ?? 0,
      correctRate: _doubleValue(json['correctRate']) ?? 0,
    );
  }

  final DateTime date;
  final int reviewCount;

  /// 백분율(0~100). 백엔드 `toRate`와 동일한 스케일.
  final double correctRate;
}

class ReviewOverview {
  const ReviewOverview({
    required this.totalReviews,
    required this.overallCorrectRate,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory ReviewOverview.fromJson(Map<String, dynamic> json) {
    return ReviewOverview(
      totalReviews: _intValue(json['totalReviews']) ?? 0,
      overallCorrectRate: _doubleValue(json['overallCorrectRate']) ?? 0,
      currentStreak: _intValue(json['currentStreak']) ?? 0,
      longestStreak: _intValue(json['longestStreak']) ?? 0,
    );
  }

  final int totalReviews;
  final double overallCorrectRate;
  final int currentStreak;
  final int longestStreak;
}

class LearningStatsApi {
  const LearningStatsApi(this._dio);

  final Dio _dio;

  Future<ReviewForecast> getForecast({
    required String tenantId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _dio.get<dynamic>(
      '/stats/forecast',
      queryParameters: {'from': _isoDate(from), 'to': _isoDate(to)},
      options: _tenantOptions(tenantId),
    );
    return ReviewForecast.fromJson(_unwrapMap(response.data));
  }

  Future<List<DeckSummary>> getDeckSummaries({
    required String tenantId,
    DateTime? date,
  }) async {
    final response = await _dio.get<dynamic>(
      '/stats/decks',
      queryParameters: {if (date != null) 'date': _isoDate(date)},
      options: _tenantOptions(tenantId),
    );
    return _listValue(_unwrapMap(response.data)['decks'])
        .whereType<Map<String, dynamic>>()
        .map(DeckSummary.fromJson)
        .toList(growable: false);
  }

  Future<List<DailyReviewStat>> getDailyStats({
    required String tenantId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _dio.get<dynamic>(
      '/stats/daily',
      queryParameters: {'from': _isoDate(from), 'to': _isoDate(to)},
      options: _tenantOptions(tenantId),
    );
    return _listValue(_unwrapMap(response.data)['days'])
        .whereType<Map<String, dynamic>>()
        .map(DailyReviewStat.fromJson)
        .toList(growable: false);
  }

  Future<ReviewOverview> getOverview({required String tenantId}) async {
    final response = await _dio.get<dynamic>(
      '/stats/overview',
      options: _tenantOptions(tenantId),
    );
    return ReviewOverview.fromJson(_unwrapMap(response.data));
  }
}

Options _tenantOptions(String tenantId) {
  return Options(headers: {'X-Tenant-Id': tenantId});
}

String _isoDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

Map<String, dynamic> _unwrapMap(Object? payload) {
  final unwrapped = _unwrapData(payload);
  if (unwrapped is Map<String, dynamic>) return unwrapped;
  if (unwrapped is Map) {
    return unwrapped.map((key, value) => MapEntry('$key', value));
  }
  throw const FormatException('Invalid learning stats API response.');
}

Object? _unwrapData(Object? payload) {
  if (payload is Map && payload.containsKey('data')) return payload['data'];
  return payload;
}

List<dynamic> _listValue(Object? value) => value is List ? value : const [];

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _doubleValue(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

DateTime? _dateValue(Object? value) {
  if (value is! String || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}
