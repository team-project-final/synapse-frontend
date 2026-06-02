part of '../gamification_screens.dart';

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
                  Text(
                    '개발자 김시냅스',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '레벨 7 · 지식 탐험가',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
            Text(
              'XP 3,240',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Lv 8까지 360',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
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
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '14일',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.streak,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '연속 · 최고 21일',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
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
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md - 3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '정답률',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '94%',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        // 배지 갤러리
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxs,
            AppSpacing.xl,
            AppSpacing.xxs,
            AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '배지 $acquired / ${_badges.length}',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
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
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
