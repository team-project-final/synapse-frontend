part of '../community_screens.dart';

class _GroupData {
  const _GroupData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.accessLabel,
    required this.joined,
    required this.lastActivity,
    required this.memberAvatars,
  });
  final String id;
  final String name;
  final String emoji;
  final String accessLabel;
  final bool joined;
  final String lastActivity;
  final List<String> memberAvatars;
}

_GroupData _groupDataFromApi(
  CommunityGroup group, {
  bool joined = false,
}) {
  return _GroupData(
    id: group.id,
    name: group.name,
    emoji: group.isPublic ? '🌐' : '🔒',
    accessLabel: group.isPublic ? '공개' : '승인제',
    joined: joined || group.joined,
    lastActivity: _formatRelativeTime(group.createdAt),
    memberAvatars: [
      if (group.name.isNotEmpty) _initial(group.name),
      if (group.ownerId.isNotEmpty)
        group.ownerId.substring(group.ownerId.length - 1),
    ],
  );
}

String _initial(String value) => value.isEmpty ? '?' : value.substring(0, 1);

const _gamificationLeaderboardRefreshQueries = [
  LeaderboardQuery(period: 'all', limit: 20),
  LeaderboardQuery(period: 'group', limit: 20),
  LeaderboardQuery(period: 'weekly', limit: 20),
  LeaderboardQuery(period: 'monthly', limit: 20),
  LeaderboardQuery(limit: 4),
];

int? _currentGamificationLevel(WidgetRef ref) {
  return ref.read(myGamificationProvider).asData?.value.level;
}

Future<void> _refreshGamificationAfterEngagementAction({
  required BuildContext context,
  required WidgetRef ref,
  required int? previousLevel,
  List<String> rewards = const [],
}) async {
  ref.invalidate(myGamificationProvider);
  ref.invalidate(badgesProvider);
  ref.invalidate(xpHistoryProvider);
  for (final query in _gamificationLeaderboardRefreshQueries) {
    ref.invalidate(leaderboardProvider(query));
  }

  try {
    final updated = await ref.read(myGamificationProvider.future);
    if (!context.mounted ||
        previousLevel == null ||
        updated.level <= previousLevel) {
      return;
    }
    await LevelUpCelebration.show(
      context,
      previousLevel: previousLevel,
      newLevel: updated.level,
      rewards: rewards,
    );
  } catch (_) {
    // Gamification 갱신 실패가 원래 engagement 액션 성공 UX를 막지 않게 둔다.
  }
}

String _formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) {
    return '최근';
  }
  final diff = DateTime.now().difference(dateTime.toLocal());
  if (diff.inMinutes < 1) return '방금';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return '${dateTime.month}/${dateTime.day}';
}
