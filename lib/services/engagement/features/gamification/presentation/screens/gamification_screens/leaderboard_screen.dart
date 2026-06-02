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
    // TODO: 팀원 구현 — engagement-svc 리더보드 API 연동
    const mockEntries = [
      _LeaderboardEntry(rank: 1, name: '박탑원', xp: 12450, isMe: false),
      _LeaderboardEntry(rank: 2, name: '이세컨', xp: 11200, isMe: false),
      _LeaderboardEntry(rank: 3, name: '최써드', xp: 9870, isMe: false),
      _LeaderboardEntry(rank: 4, name: '정포스', xp: 8540, isMe: false),
      _LeaderboardEntry(rank: 5, name: '강피프', xp: 7320, isMe: false),
      _LeaderboardEntry(rank: 6, name: '홍식스', xp: 6100, isMe: false),
      _LeaderboardEntry(rank: 7, name: '김시냅스', xp: 3240, isMe: true),
      _LeaderboardEntry(rank: 8, name: '윤에잇', xp: 2980, isMe: false),
      _LeaderboardEntry(rank: 9, name: '임나인', xp: 2150, isMe: false),
      _LeaderboardEntry(rank: 10, name: '서텐', xp: 1890, isMe: false),
    ];

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
            children: List.generate(
              4,
              (_) => ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: mockEntries.length,
                itemBuilder: (context, i) {
                  final entry = mockEntries[i];
                  return _LeaderboardRow(entry: entry);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isMe,
  });
  final int rank;
  final String name;
  final int xp;
  final bool isMe;
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});
  final _LeaderboardEntry entry;

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
        color: entry.isMe
            ? AppColors.primary.withValues(alpha: 0.10) // highlight my row
            : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: entry.isMe
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
            : null,
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
                      color: entry.isMe ? AppColors.primary : AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: entry.isMe
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surface2,
            child: Text(
              entry.name.substring(0, 1),
              style: textTheme.labelSmall?.copyWith(
                color: entry.isMe ? AppColors.primary : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Name
          Expanded(
            child: Text(
              entry.name,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: entry.isMe ? FontWeight.bold : null,
              ),
            ),
          ),
          // XP
          Text(
            '${entry.xp} XP',
            style: textTheme.bodyMedium?.copyWith(
              color: entry.isMe ? AppColors.primary : AppColors.muted,
              fontWeight: entry.isMe ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
