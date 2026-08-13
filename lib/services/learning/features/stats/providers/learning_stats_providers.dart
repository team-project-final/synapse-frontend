import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/platform/features/tenant/data/tenant_api.dart';

/// 4xx는 재시도해도 같은 결과다. Riverpod 3의 기본 재시도(최대 10회·지수 백오프)를
/// 그대로 두면 그동안 상태가 `AsyncLoading`이라 사용자에게 무한 스피너가 보인다.
///
/// public — `heatmap_provider.dart`도 동일 정책을 공유한다. 재시도 정책이
/// 두 곳에 갈라지지 않도록 이 파일이 유일한 정의처다.
Duration? skipRetryOnClientError(int retryCount, Object error) {
  final status = error is DioException ? error.response?.statusCode : null;
  if (status != null && status >= 400 && status < 500) return null;
  if (retryCount >= 3) return null;
  return Duration(milliseconds: 200 * (retryCount + 1));
}

final learningStatsApiProvider = Provider<LearningStatsApi>((ref) {
  return LearningStatsApi(ref.watch(dioProvider));
});

final reviewForecastProvider = FutureProvider.autoDispose
    .family<ReviewForecast, StatsDateRange>((ref, range) async {
      final tenant = await ref.watch(currentTenantProvider.future);
      return ref
          .watch(learningStatsApiProvider)
          .getForecast(tenantId: tenant.id, from: range.from, to: range.to);
    }, retry: skipRetryOnClientError);

final deckSummariesProvider = FutureProvider.autoDispose
    .family<List<DeckSummary>, DateTime>((ref, date) async {
      final tenant = await ref.watch(currentTenantProvider.future);
      return ref
          .watch(learningStatsApiProvider)
          .getDeckSummaries(tenantId: tenant.id, date: date);
    }, retry: skipRetryOnClientError);

final dailyReviewStatsProvider = FutureProvider.autoDispose
    .family<List<DailyReviewStat>, StatsDateRange>((ref, range) async {
      final tenant = await ref.watch(currentTenantProvider.future);
      return ref
          .watch(learningStatsApiProvider)
          .getDailyStats(tenantId: tenant.id, from: range.from, to: range.to);
    }, retry: skipRetryOnClientError);

final reviewOverviewProvider = FutureProvider.autoDispose<ReviewOverview>((
  ref,
) async {
  final tenant = await ref.watch(currentTenantProvider.future);
  return ref.watch(learningStatsApiProvider).getOverview(tenantId: tenant.id);
}, retry: skipRetryOnClientError);

/// family 키로 쓰이므로 값 동등성이 필요하다.
class StatsDateRange {
  const StatsDateRange({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StatsDateRange && other.from == from && other.to == to;
  }

  @override
  int get hashCode => Object.hash(from, to);
}
