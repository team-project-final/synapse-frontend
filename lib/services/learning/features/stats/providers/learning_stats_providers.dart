import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/platform/features/tenant/data/tenant_api.dart';

/// 4xx는 재시도해도 같은 결과다. Riverpod 3의 기본 재시도(최대 10회·지수 백오프)를
/// 그대로 두면 그동안 상태가 `AsyncLoading`이라 사용자에게 무한 스피너가 보인다.
Duration? _skipRetryOnClientError(int retryCount, Object error) {
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
    }, retry: _skipRetryOnClientError);

final deckSummariesProvider = FutureProvider.autoDispose
    .family<List<DeckSummary>, DateTime>((ref, date) async {
      final tenant = await ref.watch(currentTenantProvider.future);
      return ref
          .watch(learningStatsApiProvider)
          .getDeckSummaries(tenantId: tenant.id, date: date);
    }, retry: _skipRetryOnClientError);

final dailyReviewStatsProvider = FutureProvider.autoDispose
    .family<List<DailyReviewStat>, StatsDateRange>((ref, range) async {
      final tenant = await ref.watch(currentTenantProvider.future);
      return ref
          .watch(learningStatsApiProvider)
          .getDailyStats(tenantId: tenant.id, from: range.from, to: range.to);
    }, retry: _skipRetryOnClientError);

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
