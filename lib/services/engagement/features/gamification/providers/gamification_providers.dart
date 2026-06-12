import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/services/engagement/features/gamification/data/gamification_api.dart';

// 화면은 이 provider들을 구독해서 gamification 데이터를 받는다.
// FutureProvider가 로딩, 성공, 실패 상태를 AsyncValue로 관리한다.
// TODO(gamification-api-integration): 실제 engagement API 연결 시에도 화면 코드는 유지하고,
// fallback 제거/인증 실패 처리는 data/gamification_api.dart 안에서만 교체한다.
final myGamificationProvider = FutureProvider<UserGamification>((ref) {
  return ref.watch(gamificationApiProvider).getMyGamification();
});

final badgesProvider = FutureProvider<List<BadgeInfo>>((ref) {
  return ref.watch(gamificationApiProvider).getBadges();
});

final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, LeaderboardQuery>((
  ref,
  query,
) {
  return ref.watch(gamificationApiProvider).getLeaderboard(
        period: query.period,
        limit: query.limit,
      );
});

final xpHistoryProvider = FutureProvider<List<XpEvent>>((ref) {
  return ref.watch(gamificationApiProvider).getXpHistory();
});

// 리더보드는 기간과 limit이 바뀌면 서로 다른 요청으로 봐야 한다.
// 이 객체를 family key로 사용하려고 equality/hashCode를 직접 정의한다.
class LeaderboardQuery {
  const LeaderboardQuery({this.period = 'all', this.limit = 20});

  final String period;
  final int limit;

  @override
  bool operator ==(Object other) {
    return other is LeaderboardQuery &&
        other.period == period &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(period, limit);
}
