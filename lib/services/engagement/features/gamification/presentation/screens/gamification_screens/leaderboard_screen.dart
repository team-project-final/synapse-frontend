part of '../gamification_screens.dart';

// ── LeaderboardScreen (SCR-W-GAME-003) ──

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _periodTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            for (final tab in _periodTabs) Tab(text: tab.label),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (final tab in _periodTabs)
                _LeaderboardTab(period: tab.period),
            ],
          ),
        ),
      ],
    );
  }
}

const _periodTabs = [
  (label: '전체', period: 'all'),
  (label: '내 그룹', period: 'group'),
  (label: '주간', period: 'weekly'),
  (label: '월간', period: 'monthly'),
];

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab({required this.period});

  final String period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = LeaderboardQuery(period: period, limit: 20);
    final entriesAsync = ref.watch(leaderboardProvider(query));
    final currentUserId = userIdFromAccessToken(
      ref.watch(authNotifierProvider).accessToken,
    );

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(child: Text('리더보드 데이터가 없습니다.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: entries.length,
          itemBuilder: (context, i) => _LeaderboardRow(
            entry: entries[i],
            isMe: currentUserId != null && entries[i].userId == currentUserId,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _EngagementErrorState(
          message: '리더보드를 불러오지 못했습니다',
          onRetry: () => ref.invalidate(leaderboardProvider(query)),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.isMe});

  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final rankColor = entry.rank == 1
        ? AppColors.warning
        : entry.rank == 2
            ? AppColors.muted
            : entry.rank == 3
                ? AppColors.streak
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withValues(alpha: 0.10) : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isMe
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: entry.rank <= 3
                ? Icon(Icons.emoji_events, color: rankColor, size: 22)
                : Text(
                    '${entry.rank}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isMe ? AppColors.primary : AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 16,
            backgroundColor: isMe
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surface2,
            child: Text(
              _gamificationInitial(entry.nickname),
              style: textTheme.labelSmall?.copyWith(
                color: isMe ? AppColors.primary : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.nickname,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: isMe ? FontWeight.bold : null,
              ),
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: textTheme.bodyMedium?.copyWith(
              color: isMe ? AppColors.primary : AppColors.muted,
              fontWeight: isMe ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
