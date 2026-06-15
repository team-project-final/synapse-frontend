part of '../gamification_screens.dart';

// ── GamificationProfileScreen (SCR-W-GAME-001) ──

class GamificationProfileScreen extends ConsumerWidget {
  const GamificationProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myGamificationProvider);
    return profileAsync.when(
      data: (profile) => _GamificationProfileBody(profile: profile),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => ConceptPage(
        children: [
          _EngagementErrorState(
            message: '게이미피케이션 프로필을 불러오지 못했습니다',
            onRetry: () => ref.invalidate(myGamificationProvider),
          ),
        ],
      ),
    );
  }
}

class _GamificationProfileBody extends StatelessWidget {
  const _GamificationProfileBody({required this.profile});

  final UserGamification profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final badges = profile.badges.map(_ProfileBadge.fromInfo).toList();
    final acquired = badges.where((b) => !b.locked).length;
    final levelBaseXp = profile.level <= 1 ? 0 : (profile.level - 1) * 250;
    final nextLevelXp = profile.level * 250;
    final xpInLevel = (profile.xp - levelBaseXp).clamp(0, 250);
    final progress = xpInLevel / 250;
    final remainingXp = (nextLevelXp - profile.xp).clamp(0, 250);

    return ConceptPage(
      children: [
        Row(
          children: [
            const SynapseOrb(size: 64, glyph: 'USER', glyphScale: 0.26),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 학습 프로필',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '레벨 ${profile.level} · 지식 탐험가',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'XP ${profile.xp}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Lv ${profile.level + 1}까지 $remainingXp',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            height: 9,
            color: AppColors.surface2,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
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
              const Icon(
                Icons.local_fire_department,
                size: 18,
                color: AppColors.streak,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${profile.currentStreak}일',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.streak,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '연속 · 최고 ${profile.longestStreak}일',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const ConceptSectionLabel('누적 활동'),
        ConceptStatRow(
          children: [
            ConceptStat(value: '${profile.currentStreak}', label: '현재 스트릭'),
            ConceptStat(value: '${profile.longestStreak}', label: '최고 스트릭'),
            ConceptStat(
              value: '${profile.xp}',
              label: 'XP',
              color: AppColors.primary,
            ),
          ],
        ),
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
                '배지 $acquired / ${badges.length}',
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
                child: const Text('전체 보기'),
              ),
            ],
          ),
        ),
        if (badges.isEmpty)
          const ConceptCard(child: Text('아직 표시할 배지가 없습니다.'))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 8 : 4,
              crossAxisSpacing: AppSpacing.sm + 4,
              mainAxisSpacing: AppSpacing.sm + 4,
              childAspectRatio: 0.78,
            ),
            itemCount: badges.length,
            itemBuilder: (context, i) => _ProfileBadgeTile(badge: badges[i]),
          ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => context.go(AppRoutes.gamificationXpHistory),
              child: const Text('XP 이력 보기'),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.gamificationLeaderboard),
              child: const Text('리더보드 보기'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _ProfileBadge {
  const _ProfileBadge({
    required this.icon,
    required this.name,
    required this.locked,
  });

  factory _ProfileBadge.fromInfo(BadgeInfo info) {
    return _ProfileBadge(
      icon: _badgeIcon(info.conditionType),
      name: info.name,
      locked: !info.acquired,
    );
  }

  final IconData icon;
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
              child: Icon(
                badge.icon,
                size: 26,
                color: badge.locked ? AppColors.muted : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 1),
        Flexible(
          child: Text(
            badge.locked ? '잠김' : badge.name,
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

IconData _badgeIcon(String conditionType) {
  return switch (conditionType.toUpperCase()) {
    'STREAK' => Icons.local_fire_department,
    'XP' => Icons.workspace_premium,
    'LEVEL' => Icons.emoji_events,
    'NOTE' => Icons.article_outlined,
    'CARD' || 'REVIEW' => Icons.refresh,
    _ => Icons.military_tech,
  };
}

class _EngagementErrorState extends StatelessWidget {
  const _EngagementErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ConceptCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
