import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

// ── GamificationProfileScreen (SCR-W-GAME-001) ──

class GamificationProfileScreen extends ConsumerWidget {
  const GamificationProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — engagement-svc 게이미피케이션 프로필 API 연동
    const acquiredBadgeData = [
      _BadgeInfo(icon: Icons.star, name: '노트 마스터', condition: '노트 50개 작성', date: '2026-04-10'),
      _BadgeInfo(icon: Icons.military_tech, name: '7일 연속', condition: '7일 연속 학습', date: '2026-05-01'),
      _BadgeInfo(icon: Icons.emoji_events, name: '첫 복습', condition: '첫 번째 복습 완료', date: '2026-03-15'),
      _BadgeInfo(icon: Icons.local_fire_department, name: '불꽃 학습', condition: '하루 50장 복습', date: '2026-05-10'),
      _BadgeInfo(icon: Icons.school, name: '지식 탐험가', condition: '레벨 7 달성', date: '2026-05-15'),
      _BadgeInfo(icon: Icons.lightbulb, name: 'AI 활용', condition: 'AI 카드 생성 10회', date: '2026-04-20'),
      _BadgeInfo(icon: Icons.workspace_premium, name: '프리미엄', condition: 'Pro 플랜 가입', date: '2026-03-01'),
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
                    const SynapseOrb(size: 60, glyph: '🧑‍💻', glyphScale: 0.5),
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
                              color: AppColors.primary
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.xs),
                            ),
                            child: Text(
                              '레벨 7 — 지식 탐험가',
                              style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary),
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
                            ?.copyWith(color: AppColors.muted)),
                        Text('3,240 / 5,000 XP',
                            style: textTheme.bodySmall?.copyWith(
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // primary→accent 그라데이션 XP 바 (목업 xpbar)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Container(
                        height: 9,
                        color: AppColors.surface2,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.65,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                              ),
                            ),
                          ),
                        ),
                      ),
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
                            ?.copyWith(color: AppColors.text)),
                    // TODO: 팀원 구현 — 연속 학습 스트릭 데이터 연동
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Weekly stats row
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이번 주 통계', style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _WeeklyStat(
                        icon: Icons.style_outlined,
                        label: '복습',
                        value: '78장'),
                    _WeeklyStat(
                        icon: Icons.article_outlined,
                        label: '노트',
                        value: '12개'),
                    _WeeklyStat(
                        icon: Icons.bolt,
                        label: 'XP',
                        value: '450'),
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
          children: acquiredBadgeData
              .map((badge) => GestureDetector(
                    onTap: () => _showBadgeDetail(context, badge),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.sm),
                        border:
                            Border.all(color: AppColors.border),
                      ),
                      child: Icon(badge.icon,
                          color: AppColors.primary, size: 24),
                    ),
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
                const Row(
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

  void _showBadgeDetail(BuildContext context, _BadgeInfo badge) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badge.icon,
                  size: 48, color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(badge.name, style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '조건: ${badge.condition}',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '획득일: ${badge.date}',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeInfo {
  const _BadgeInfo({
    required this.icon,
    required this.name,
    required this.condition,
    required this.date,
  });
  final IconData icon;
  final String name;
  final String condition;
  final String date;
}

class _WeeklyStat extends StatelessWidget {
  const _WeeklyStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(value,
            style: textTheme.titleSmall
                ?.copyWith(color: AppColors.primary)),
        Text(label,
            style: textTheme.bodySmall
                ?.copyWith(color: AppColors.muted)),
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
                ?.copyWith(color: AppColors.primary)),
        const SizedBox(height: AppSpacing.xxs),
        Text(label,
            style: textTheme.bodySmall
                ?.copyWith(color: AppColors.muted)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.border);
  }
}

// ── BadgeGalleryScreen (SCR-W-GAME-002) ──

class BadgeGalleryScreen extends ConsumerStatefulWidget {
  const BadgeGalleryScreen({super.key});

  @override
  ConsumerState<BadgeGalleryScreen> createState() =>
      _BadgeGalleryScreenState();
}

class _BadgeGalleryScreenState extends ConsumerState<BadgeGalleryScreen> {
  String _filterSelection = '전체';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    // TODO: 팀원 구현 — engagement-svc 배지 갤러리 API 연동
    const acquiredBadges = [
      _Badge(name: '첫 노트', icon: Icons.article_outlined, acquired: true, condition: '첫 번째 노트 작성', progress: 1.0),
      _Badge(name: '첫 복습', icon: Icons.refresh, acquired: true, condition: '첫 번째 복습 완료', progress: 1.0),
      _Badge(name: '7일 연속', icon: Icons.local_fire_department, acquired: true, condition: '7일 연속 학습', progress: 1.0),
      _Badge(name: '노트 마스터', icon: Icons.star, acquired: true, condition: '노트 50개 작성', progress: 1.0),
      _Badge(name: '지식 탐험가', icon: Icons.explore, acquired: true, condition: '레벨 7 달성', progress: 1.0),
      _Badge(name: 'AI 활용', icon: Icons.auto_awesome, acquired: true, condition: 'AI 카드 생성 10회', progress: 1.0),
    ];
    const lockedBadges = [
      _Badge(name: '30일 연속', icon: Icons.military_tech, acquired: false, condition: '30일 연속 학습', progress: 0.47),
      _Badge(name: '카드 100장', icon: Icons.style, acquired: false, condition: '카드 100장 생성', progress: 0.72),
      _Badge(name: '그룹 참여', icon: Icons.groups, acquired: false, condition: '그룹 3개 참여', progress: 0.33),
      _Badge(name: '공유 왕', icon: Icons.share, acquired: false, condition: '덱 5개 공유', progress: 0.2),
      _Badge(name: '레벨 10', icon: Icons.emoji_events, acquired: false, condition: '레벨 10 달성', progress: 0.7),
      _Badge(name: '1000 XP', icon: Icons.workspace_premium, acquired: false, condition: '1000 XP 달성', progress: 0.65),
    ];

    List<_Badge> filteredBadges;
    switch (_filterSelection) {
      case '획득':
        filteredBadges = acquiredBadges;
      case '미획득':
        filteredBadges = lockedBadges;
      default:
        filteredBadges = [...acquiredBadges, ...lockedBadges];
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            Text('배지 갤러리', style: textTheme.titleLarge),
            const Spacer(),
            Text('12/30 획득',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // ChoiceChip filter row
        Wrap(
          spacing: AppSpacing.sm,
          children: ['전체', '획득', '미획득'].map((label) {
            final selected = _filterSelection == label;
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) =>
                  setState(() => _filterSelection = label),
            );
          }).toList(),
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
          itemCount: filteredBadges.length,
          itemBuilder: (context, i) => _BadgeTile(
            badge: filteredBadges[i],
            onTap: () =>
                _showBadgeBottomSheet(context, filteredBadges[i]),
          ),
        ),
      ],
    );
  }

  void _showBadgeBottomSheet(BuildContext context, _Badge badge) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badge.icon,
                  size: 48,
                  color: badge.acquired
                      ? AppColors.primary
                      : AppColors.muted),
              const SizedBox(height: AppSpacing.md),
              Text(
                badge.acquired ? badge.name : '잠김',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '조건: ${badge.condition}',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.md),
              // Progress indicator
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: badge.progress,
                      backgroundColor: AppColors.border,
                      color: badge.acquired
                          ? AppColors.success
                          : AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.xs),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${(badge.progress * 100).toInt()}%',
                    style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

class _Badge {
  const _Badge({
    required this.name,
    required this.icon,
    required this.acquired,
    required this.condition,
    required this.progress,
  });
  final String name;
  final IconData icon;
  final bool acquired;
  final String condition;
  final double progress;
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, this.onTap});
  final _Badge badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: badge.acquired ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                    badge.acquired ? AppColors.surface2 : AppColors.bg,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(
                  color: badge.acquired
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                badge.icon,
                size: 32,
                color: badge.acquired
                    ? AppColors.primary
                    : AppColors.muted,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              badge.acquired ? badge.name : '잠김',
              style: textTheme.bodySmall?.copyWith(
                color: badge.acquired ? null : AppColors.muted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
            ? AppColors.muted
            : entry.rank == 3
                ? const Color(0xFFCD7F32) // bronze
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                          ? AppColors.primary
                          : AppColors.muted,
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
              color: entry.isMe
                  ? AppColors.primary
                  : AppColors.muted,
              fontWeight: entry.isMe ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
