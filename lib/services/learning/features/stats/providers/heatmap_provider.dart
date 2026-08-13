import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/learning/features/stats/providers/learning_stats_providers.dart';
import 'package:synapse_frontend/services/platform/features/tenant/data/tenant_api.dart';

/// 잔디밭 히트맵 칸 수 — 52주 × 7일.
const int heatmapDays = 364;

/// 백엔드 구간 상한(92일)에 맞춰 나눈 청크 크기.
const int _chunkDays = 91;

/// 최근 [heatmapDays]일의 일별 실적. 오래된 날짜가 앞에 온다.
final heatmapDailyStatsProvider =
    FutureProvider.autoDispose<List<DailyReviewStat>>((ref) async {
      final tenant = await ref.watch(currentTenantProvider.future);
      final api = ref.watch(learningStatsApiProvider);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(const Duration(days: heatmapDays - 1));

      final result = <DailyReviewStat>[];
      var from = start;
      while (!from.isAfter(today)) {
        final candidate = from.add(const Duration(days: _chunkDays - 1));
        final to = candidate.isAfter(today) ? today : candidate;
        result.addAll(
          await api.getDailyStats(tenantId: tenant.id, from: from, to: to),
        );
        from = to.add(const Duration(days: 1));
      }
      return result;
    }, retry: skipRetryOnClientError);
