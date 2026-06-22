part of '../gamification_screens.dart';

// ── GamificationProfileScreen (SCR-W-GAME-001) ──

class GamificationProfileScreen extends ConsumerWidget {
  const GamificationProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileValue = ref.watch(gamificationProfileProvider);

    return AppAsyncValueWidget<GamificationProfile>(
      value: profileValue,
      loading: const AppLoadingWidget(label: '게이미피케이션 프로필을 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '게이미피케이션 프로필을 불러오지 못했습니다.',
        onRetry: () => ref.invalidate(gamificationProfileProvider),
      ),
      data: (profile) => _GamificationProfileView(profile: profile),
    );
  }
}

class _GamificationProfileView extends StatelessWidget {
  const _GamificationProfileView({required this.profile});

  final GamificationProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final badges = profile.badges;

    return ConceptPage(
      children: [
        Row(
          children: [
            const SynapseOrb(size: 64, glyph: 'XP', glyphScale: 0.38),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 학습 레벨',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '레벨 ${profile.level} · 누적 ${_formatCount(profile.xp)} XP',
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
              'XP ${_formatCount(profile.xp)}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Lv ${profile.level + 1}까지 ${_formatCount(profile.remainingXp)}',
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
              widthFactor: profile.levelProgress,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryHover],
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
        const ConceptSectionLabel('상태'),
        ConceptStatRow(
          children: [
            ConceptStat(value: '${profile.level}', label: '레벨'),
            ConceptStat(
              value: _formatCount(profile.xp),
              label: '누적 XP',
              color: AppColors.primary,
            ),
            ConceptStat(value: '${badges.length}', label: '획득 배지'),
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
                '획득 배지 ${badges.length}',
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
        if (badges.isEmpty)
          const ConceptEmptyState(
            emoji: '☆',
            title: '아직 획득한 배지가 없습니다',
            body: '복습, 노트 작성, 연속 학습을 진행하면 배지가 표시됩니다.',
          )
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
              child: const Text('XP 이력 보기 →'),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.gamificationLeaderboard),
              child: const Text('리더보드 보기 →'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _ProfileBadgeTile extends StatelessWidget {
  const _ProfileBadgeTile({required this.badge});
  final GamificationBadge badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: AppColors.primary,
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

String _formatCount(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(text[i]);
  }
  return buffer.toString();
}
