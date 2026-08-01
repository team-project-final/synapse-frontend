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

  static const _tabs = [
    (label: '전체', period: 'all'),
    (label: '주간', period: 'weekly'),
    (label: '월간', period: 'monthly'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
          tabs: [for (final tab in _tabs) Tab(text: tab.label)],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (final tab in _tabs)
                _LeaderboardList(
                  query: LeaderboardQuery(period: tab.period, limit: 20),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardList extends ConsumerWidget {
  const _LeaderboardList({required this.query});

  final LeaderboardQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesValue = ref.watch(leaderboardProvider(query));

    return AppAsyncValueWidget<List<LeaderboardEntry>>(
      value: entriesValue,
      loading: const AppLoadingWidget(label: '리더보드를 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '리더보드를 불러오지 못했습니다.',
        onRetry: () => ref.invalidate(leaderboardProvider(query)),
      ),
      isEmpty: (entries) => entries.isEmpty,
      empty: const AppEmptyState(
        icon: Icons.leaderboard_outlined,
        title: '리더보드 항목이 없습니다.',
      ),
      data: (entries) => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: entries.length,
        itemBuilder: (context, i) => _LeaderboardRow(entry: entries[i]),
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
        ? const Color(0xFFCD7F32)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
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
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surface2,
            child: Text(
              entry.nickname.isEmpty ? '?' : entry.nickname.substring(0, 1),
              style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Lv ${entry.level}',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              '${_formatCount(entry.xp)} XP',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
