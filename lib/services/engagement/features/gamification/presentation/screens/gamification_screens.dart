import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── GamificationProfileScreen (SCR-W-GAME-001) ──

class GamificationProfileScreen extends ConsumerWidget {
  const GamificationProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: 팀원 구현 — engagement-svc 게이미피케이션 프로필 API 연동
    const acquiredBadgeIcons = [
      Icons.star,
      Icons.military_tech,
      Icons.emoji_events,
      Icons.local_fire_department,
      Icons.school,
      Icons.lightbulb,
      Icons.workspace_premium,
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Header card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text('김',
                          style: textTheme.headlineSmall
                              ?.copyWith(color: colorScheme.primary)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('김시냅스',
                              style: textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.xxs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAmber
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.xs),
                            ),
                            child: Text(
                              '레벨 7 — 지식 탐험가',
                              style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.primaryAmber),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // XP bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('경험치', style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.stone500)),
                        Text('3,240 / 5,000 XP',
                            style: textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryAmber)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: 0.65,
                      backgroundColor: AppColors.stone200,
                      color: AppColors.primaryAmber,
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                      minHeight: 8,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Streak
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.deepOrange, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Text('연속 학습 14일',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.stone600)),
                    // TODO: 팀원 구현 — 연속 학습 스트릭 데이터 연동
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Badge section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('획득한 배지 (12/30)', style: textTheme.titleMedium),
            TextButton(
              onPressed: () => context.go(AppRoutes.gamificationBadges),
              child: const Text('전체 보기 →'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: acquiredBadgeIcons
              .map((icon) => Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.stone100,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(color: AppColors.stone200),
                    ),
                    child: Icon(icon,
                        color: AppColors.primaryAmber, size: 24),
                  ))
              .toList(),
        ),
        // TODO: 팀원 구현 — 획득 배지 목록 API 연동
        const SizedBox(height: AppSpacing.md),

        // Stats section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(label: '복습 카드', value: '152장'),
                    _VerticalDivider(),
                    _ProfileStat(label: '노트', value: '8개'),
                    _VerticalDivider(),
                    _ProfileStat(label: 'XP', value: '+420'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.go(AppRoutes.gamificationLeaderboard),
                    child: const Text('리더보드 보기 →'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // TODO: 팀원 구현 — 학습 통계 데이터 API 연동
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value,
            style: textTheme.titleMedium
                ?.copyWith(color: AppColors.primaryAmber)),
        const SizedBox(height: AppSpacing.xxs),
        Text(label,
            style: textTheme.bodySmall
                ?.copyWith(color: AppColors.stone500)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.stone200);
  }
}

// ── BadgeGalleryScreen (SCR-W-GAME-002) ──

class BadgeGalleryScreen extends ConsumerWidget {
  const BadgeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    // TODO: 팀원 구현 — engagement-svc 배지 갤러리 API 연동
    final acquiredBadges = [
      _Badge(name: '첫 노트', icon: Icons.article_outlined, acquired: true),
      _Badge(name: '첫 복습', icon: Icons.refresh, acquired: true),
      _Badge(name: '7일 연속', icon: Icons.local_fire_department, acquired: true),
      _Badge(name: '노트 마스터', icon: Icons.star, acquired: true),
      _Badge(name: '지식 탐험가', icon: Icons.explore, acquired: true),
      _Badge(name: 'AI 활용', icon: Icons.auto_awesome, acquired: true),
    ];
    final lockedBadges = [
      _Badge(name: '30일 연속', icon: Icons.military_tech, acquired: false),
      _Badge(name: '카드 100장', icon: Icons.style, acquired: false),
      _Badge(name: '그룹 참여', icon: Icons.groups, acquired: false),
      _Badge(name: '공유 왕', icon: Icons.share, acquired: false),
      _Badge(name: '레벨 10', icon: Icons.emoji_events, acquired: false),
      _Badge(name: '1000 XP', icon: Icons.workspace_premium, acquired: false),
    ];

    final allBadges = [...acquiredBadges, ...lockedBadges];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            Text('배지 갤러리', style: textTheme.titleLarge),
            const Spacer(),
            Text('12/30 획득',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone400)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 3 : 4,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.85,
          ),
          itemCount: allBadges.length,
          itemBuilder: (context, i) => _BadgeTile(badge: allBadges[i]),
        ),
      ],
    );
  }
}

class _Badge {
  const _Badge({
    required this.name,
    required this.icon,
    required this.acquired,
  });
  final String name;
  final IconData icon;
  final bool acquired;
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: badge.acquired ? 1.0 : 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: badge.acquired ? AppColors.stone100 : AppColors.stone50,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border: Border.all(
                color: badge.acquired
                    ? AppColors.primaryAmber.withValues(alpha: 0.3)
                    : AppColors.stone200,
              ),
            ),
            child: Icon(
              badge.icon,
              size: 32,
              color: badge.acquired
                  ? AppColors.primaryAmber
                  : AppColors.stone300,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            badge.acquired ? badge.name : '잠김',
            style: textTheme.bodySmall?.copyWith(
              color: badge.acquired ? null : AppColors.stone400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── LeaderboardScreen (SCR-W-GAME-003) ──

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() =>
      _LeaderboardScreenState();
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
    final mockEntries = [
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
                padding: const EdgeInsets.all(AppSpacing.md),
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
            ? AppColors.stone400
            : entry.rank == 3
                ? const Color(0xFFCD7F32) // bronze
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: entry.isMe
            ? const Color(0xFFFEF3C7) // highlight my row
            : null,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: entry.isMe
            ? Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: entry.rank <= 3
                ? Icon(
                    Icons.emoji_events,
                    color: rankColor,
                    size: 22,
                  )
                : Text(
                    '${entry.rank}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: entry.isMe
                          ? AppColors.primaryAmber
                          : AppColors.stone500,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: entry.isMe
                ? AppColors.primaryAmber.withValues(alpha: 0.2)
                : AppColors.stone100,
            child: Text(
              entry.name.substring(0, 1),
              style: textTheme.labelSmall?.copyWith(
                color: entry.isMe ? AppColors.primaryAmber : AppColors.stone500,
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
              color: entry.isMe
                  ? AppColors.primaryAmber
                  : AppColors.stone500,
              fontWeight: entry.isMe ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
