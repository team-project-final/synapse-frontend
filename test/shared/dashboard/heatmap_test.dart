import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/learning/features/stats/providers/heatmap_provider.dart';
import 'package:synapse_frontend/services/learning/features/stats/providers/learning_stats_providers.dart';
import 'package:synapse_frontend/services/platform/features/tenant/data/tenant_api.dart';

class _FakeStatsApi implements LearningStatsApi {
  final ranges = <String>[];

  @override
  Future<List<DailyReviewStat>> getDailyStats({
    required String tenantId,
    required DateTime from,
    required DateTime to,
  }) async {
    ranges.add('${from.toIso8601String()}~${to.toIso8601String()}');
    return [DailyReviewStat(date: from, reviewCount: 1, correctRate: 100)];
  }

  @override
  Future<ReviewForecast> getForecast({
    required String tenantId,
    required DateTime from,
    required DateTime to,
  }) async => const ReviewForecast(overdueCount: 0, days: []);

  @override
  Future<List<DeckSummary>> getDeckSummaries({
    required String tenantId,
    DateTime? date,
  }) async => const [];

  @override
  Future<ReviewOverview> getOverview({required String tenantId}) async =>
      const ReviewOverview(
        totalReviews: 0,
        overallCorrectRate: 0,
        currentStreak: 0,
        longestStreak: 0,
      );
}

void main() {
  test('히트맵은 364일을 92일 이하 구간으로 나눠 호출한다', () async {
    final api = _FakeStatsApi();
    final container = ProviderContainer(
      overrides: [
        learningStatsApiProvider.overrideWithValue(api),
        currentTenantProvider.overrideWith(
          (ref) async => const CurrentTenant(
            id: 'tenant-1',
            name: 'Synapse',
            plan: 'FREE',
            status: 'ACTIVE',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(heatmapDailyStatsProvider.future);

    expect(api.ranges.length, 4);
  });
}
