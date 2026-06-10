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
    _tabController = TabController(length: 4, vsync: this);
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
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '내 그룹'),
            Tab(text: '주간'),
            Tab(text: '월간'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _LeaderboardTab(period: 'all'),
              _LeaderboardTab(period: 'group'),
              _LeaderboardTab(period: 'weekly'),
              _LeaderboardTab(period: 'monthly'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab({required this.period});

  final String period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(
      leaderboardProvider(LeaderboardQuery(period: period, limit: 20)),
    );

    return entriesAsync.when(
      data: (entries) => entries.isEmpty
          ? const Center(child: Text('아직 리더보드 데이터가 없습니다'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: entries.length,
              itemBuilder: (context, i) => _LeaderboardRow(entry: entries[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _GameErrorState(
        message: '리더보드를 불러오지 못했습니다',
        onRetry: () => ref.invalidate(
          leaderboardProvider(LeaderboardQuery(period: period, limit: 20)),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final rankColor = entry.rank == 1
        ? AppColors.warning
        : entry.rank == 2
        ? AppColors.muted
        : entry.rank == 3
        ? const Color(0xFFCD7F32) // bronze
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: null,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: entry.rank <= 3
                ? Icon(Icons.emoji_events, color: rankColor, size: 22)
                : Text(
                    '${entry.rank}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surface2,
            child: Text(
              entry.nickname.isEmpty ? '?' : entry.nickname.substring(0, 1),
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Name
          Expanded(
            child: Text(
              entry.nickname,
              style: textTheme.bodyMedium,
            ),
          ),
          // XP
          Text(
            '${entry.xp} XP',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
