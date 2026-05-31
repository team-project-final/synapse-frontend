import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

// ── GamificationProfileScreen (SCR-W-GAME-001) ──

class GamificationProfileScreen extends ConsumerWidget {
  const GamificationProfileScreen({super.key});

  // v1 ⑩: 배지 갤러리 5/8(획득 5, 잠금 3) — 이모지 + 이름.
  // TODO: 팀원 구현 — engagement-svc 게이미피케이션 프로필 API 연동
  static const _badges = [
    _ProfileBadge(emoji: '📝', name: '첫 노트', locked: false),
    _ProfileBadge(emoji: '🎯', name: '첫 복습', locked: false),
    _ProfileBadge(emoji: '🔥', name: '연속 7일', locked: false),
    _ProfileBadge(emoji: '💯', name: '복습 100회', locked: false),
    _ProfileBadge(emoji: '⭐', name: '레벨 5', locked: false),
    _ProfileBadge(emoji: '🗓️', name: '연속 30일', locked: true),
    _ProfileBadge(emoji: '📚', name: '노트 50개', locked: true),
    _ProfileBadge(emoji: '🏆', name: '레벨 10', locked: true),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final acquired = _badges.where((b) => !b.locked).length;

    return ConceptPage(
      children: [
        // 헤더: 아바타(orb) + 이름 + 레벨
        Row(
          children: [
            const SynapseOrb(size: 64, glyph: '🧑‍💻', glyphScale: 0.44),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('개발자 김시냅스',
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('레벨 7 · 지식 탐험가',
                      style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // XP 바 (Lv 8까지 360 — 90%)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('XP 3,240',
                style: textTheme.labelMedium?.copyWith(
                    color: AppColors.muted, fontWeight: FontWeight.w700)),
            Text('Lv 8까지 360',
                style: textTheme.labelMedium?.copyWith(
                    color: AppColors.muted, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // primary→accent 그라데이션 XP 바 (목업 xpbar)
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            height: 9,
            color: AppColors.surface2,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.90,
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
        const SizedBox(height: AppSpacing.md),
        // 스트릭 배너 (연속 + 최고)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          decoration: BoxDecoration(
            color: AppColors.streak.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.streak.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Text('14일',
                  style: textTheme.titleMedium?.copyWith(
                      color: AppColors.streak, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Text('연속 · 최고 21일',
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        // 이번 주 통계 statgrid
        const ConceptSectionLabel('이번 주'),
        const ConceptStatRow(
          children: [
            ConceptStat(value: '152', label: '복습'),
            ConceptStat(value: '8', label: '새 노트'),
            ConceptStat(value: '+420', label: 'XP', color: AppColors.primary),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        // 정답률 행 (full-width stat)
        ConceptCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md - 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('정답률',
                  style: textTheme.labelMedium?.copyWith(
                      color: AppColors.muted, fontWeight: FontWeight.w600)),
              Text('94%',
                  style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.success, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        // 배지 갤러리
        Padding(
          padding: const EdgeInsets.fromLTRB(2, AppSpacing.xl, 2, AppSpacing.sm + 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('배지 $acquired / ${_badges.length}',
                  style: textTheme.labelLarge?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              TextButton(
                onPressed: () => context.go(AppRoutes.gamificationBadges),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('전체 보기 →'),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 8 : 4,
            crossAxisSpacing: AppSpacing.sm + 4,
            mainAxisSpacing: AppSpacing.sm + 4,
            childAspectRatio: 0.78,
          ),
          itemCount: _badges.length,
          itemBuilder: (context, i) => _ProfileBadgeTile(badge: _badges[i]),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go(AppRoutes.gamificationLeaderboard),
            child: const Text('리더보드 보기 →'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// 프로필 배지(이모지). v1 `.badge2` — 정사각 라운드 + 잠금 시 그레이/반투명.
class _ProfileBadge {
  const _ProfileBadge({
    required this.emoji,
    required this.name,
    required this.locked,
  });
  final String emoji;
  final String name;
  final bool locked;
}

class _ProfileBadgeTile extends StatelessWidget {
  const _ProfileBadgeTile({required this.badge});
  final _ProfileBadge badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Opacity(
            opacity: badge.locked ? 0.4 : 1,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badge.locked
                    ? AppColors.surface2
                    : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(badge.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 1),
        Flexible(
          child: Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
                color: AppColors.muted, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
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
