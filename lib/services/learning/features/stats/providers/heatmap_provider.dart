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

      // 구간 경계만 먼저 계산한다(91일씩, 마지막 구간은 오늘까지) — 이
      // 로직 자체는 그대로 두고, 실제 호출만 순차 대신 병렬로 보낸다.
      final ranges = <({DateTime from, DateTime to})>[];
      var from = start;
      while (!from.isAfter(today)) {
        final candidate = from.add(const Duration(days: _chunkDays - 1));
        final to = candidate.isAfter(today) ? today : candidate;
        ranges.add((from: from, to: to));
        from = to.add(const Duration(days: 1));
      }

      final chunks = await Future.wait(
        ranges.map(
          (r) => api.getDailyStats(tenantId: tenant.id, from: r.from, to: r.to),
        ),
      );
      return [for (final chunk in chunks) ...chunk];
    }, retry: skipRetryOnClientError);
