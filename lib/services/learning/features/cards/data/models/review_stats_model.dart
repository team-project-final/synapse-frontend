import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_stats.dart';

class DailyStatModel {
  const DailyStatModel({
    required this.date,
    required this.reviewCount,
    required this.correctRate,
  });

  factory DailyStatModel.fromJson(Map<String, dynamic> json) {
    return DailyStatModel(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      correctRate: (json['correctRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final DateTime date;
  final int reviewCount;
  final double correctRate;

  DailyStat toEntity() => DailyStat(
        date: date,
        reviewCount: reviewCount,
        correctRate: correctRate,
      );
}

class ReviewStatsModel {
  const ReviewStatsModel({
    required this.daily,
    required this.totalReviews,
    required this.overallCorrectRate,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory ReviewStatsModel.fromJson(Map<String, dynamic> json) {
    final dailyJson = json['daily'] as List<dynamic>? ?? [];
    return ReviewStatsModel(
      daily: dailyJson
          .map((e) => DailyStatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      overallCorrectRate: (json['overallCorrectRate'] as num?)?.toDouble() ?? 0.0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
    );
  }

  final List<DailyStatModel> daily;
  final int totalReviews;
  final double overallCorrectRate;
  final int currentStreak;
  final int longestStreak;

  ReviewStats toEntity() => ReviewStats(
        daily: daily.map((d) => d.toEntity()).toList(),
        totalReviews: totalReviews,
        overallCorrectRate: overallCorrectRate,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );
}
