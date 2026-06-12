class RetentionPoint {
  const RetentionPoint({
    required this.date,
    required this.daysAgo,
    required this.reviewCount,
    required this.retentionRate,
  });

  final DateTime date;
  final int daysAgo;
  final int reviewCount;
  final double retentionRate; // 0–100
}

class ReviewRetention {
  const ReviewRetention({required this.points});
  final List<RetentionPoint> points;
}

class WeeklyHeatmapEntry {
  const WeeklyHeatmapEntry({
    required this.weekStart,
    required this.reviewCount,
    required this.correctRate,
  });

  final DateTime weekStart;
  final int reviewCount;
  final double correctRate; // 0–100
}

class ReviewHeatmap {
  const ReviewHeatmap({required this.weekly});
  final List<WeeklyHeatmapEntry> weekly;
}

class DailyStat {
  const DailyStat({
    required this.date,
    required this.reviewCount,
    required this.correctRate,
  });

  final DateTime date;
  final int reviewCount;
  final double correctRate;
}

class ReviewStats {
  const ReviewStats({
    required this.daily,
    required this.totalReviews,
    required this.overallCorrectRate,
    required this.currentStreak,
    required this.longestStreak,
  });

  final List<DailyStat> daily;
  final int totalReviews;
  final double overallCorrectRate;
  final int currentStreak;
  final int longestStreak;
}
