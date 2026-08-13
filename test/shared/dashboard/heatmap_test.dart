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

    // 캡처한 "from~to" 구간들을 파싱해 청크 경계를 검증한다: 각 구간이
    // 92일(백엔드 상한) 이하인지, 인접 구간 사이에 중복·공백이 없는지,
    // 전체 합집합이 정확히 364일인지.
    final parsed = api.ranges.map((range) {
      final parts = range.split('~');
      return (
        from: DateTime.parse(parts[0]),
        to: DateTime.parse(parts[1]),
      );
    }).toList();

    var totalDays = 0;
    for (var i = 0; i < parsed.length; i++) {
      final (from: from, to: to) = parsed[i];
      final spanDays = to.difference(from).inDays + 1;
      expect(
        spanDays,
        lessThanOrEqualTo(92),
        reason: '구간 $i(${parsed[i]})이 92일 상한을 넘음',
      );
      totalDays += spanDays;

      if (i > 0) {
        final previousTo = parsed[i - 1].to;
        expect(
          from.difference(previousTo).inDays,
          1,
          reason: '구간 ${i - 1}과 $i 사이에 중복 또는 공백이 있음',
        );
      }
    }
    expect(totalDays, heatmapDays);
  });
}
