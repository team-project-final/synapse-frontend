part of '../gamification_screens.dart';

class GamificationProfileScreen extends ConsumerWidget {
  const GamificationProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myGamificationProvider);

    return profileAsync.when(
      data: (profile) => _GamificationProfileBody(profile: profile),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _GameErrorState(
        message: '게이미피케이션 프로필을 불러오지 못했습니다',
        onRetry: () => ref.invalidate(myGamificationProvider),
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
    final nextLevelXp = profile.level * 100;
    final currentLevelBase = (profile.level - 1).clamp(0, 999).toInt() * 100;
    final progress = nextLevelXp <= currentLevelBase
        ? 1.0
        : ((profile.xp - currentLevelBase) / (nextLevelXp - currentLevelBase))
              .clamp(0.0, 1.0)
              .toDouble();
    final remaining = (nextLevelXp - profile.xp).clamp(0, 999999).toInt();
    final badges = profile.badges.take(8).toList(growable: false);

    return ConceptPage(
      children: [
        Row(
          children: [
            const SynapseOrb(size: 64, glyph: 'XP', glyphScale: 0.28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 성장 프로필',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '레벨 ${profile.level} · 누적 ${profile.xp} XP',
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
              'Lv ${profile.level + 1}까지 $remaining',
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
              const Text('🔥', style: TextStyle(fontSize: 16)),
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
        const ConceptSectionLabel('요약'),
        ConceptStatRow(
          children: [
            ConceptStat(value: '${profile.level}', label: '레벨'),
            ConceptStat(value: '${profile.badges.length}', label: '획득 배지'),
            ConceptStat(
              value: '${profile.currentStreak}',
              label: '연속일',
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
                '획득 배지 ${profile.badges.length}',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.gamificationBadges),
                child: const Text('전체 보기 →'),
              ),
            ],
          ),
        ),
        if (badges.isEmpty)
          const ConceptCard(child: Text('아직 획득한 배지가 없습니다.'))
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

  final BadgeInfo badge;

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
            child: Icon(_badgeIcon(badge.code), color: AppColors.primary),
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

IconData _badgeIcon(String code) {
  if (code.contains('STREAK')) return Icons.local_fire_department;
  if (code.contains('LEVEL')) return Icons.emoji_events;
  if (code.contains('REVIEW')) return Icons.refresh;
  if (code.contains('SHARE')) return Icons.share;
  return Icons.workspace_premium;
}

class _GameErrorState extends StatelessWidget {
  const _GameErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, color: AppColors.stone400),
          const SizedBox(height: AppSpacing.sm),
          Text(message),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
