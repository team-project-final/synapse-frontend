part of '../gamification_screens.dart';

// ── BadgeGalleryScreen (SCR-W-GAME-002) ──

class BadgeGalleryScreen extends ConsumerStatefulWidget {
  const BadgeGalleryScreen({super.key});

  @override
  ConsumerState<BadgeGalleryScreen> createState() => _BadgeGalleryScreenState();
}

class _BadgeGalleryScreenState extends ConsumerState<BadgeGalleryScreen> {
  String _filterSelection = '전체';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final badgesAsync = ref.watch(badgesProvider);
    final profileAsync = ref.watch(myGamificationProvider);

    return badgesAsync.when(
      data: (allBadges) {
        final earnedCodes = profileAsync.maybeWhen(
          data: (profile) => profile.badges.map((badge) => badge.code).toSet(),
          orElse: () => <String>{},
        );
        final badges = allBadges
            .map(
              (badge) => _Badge(
                name: badge.name,
                icon: _badgeIcon(badge.code),
                acquired: earnedCodes.contains(badge.code) || badge.acquired,
                condition: badge.description.isEmpty
                    ? '${badge.conditionType} ${badge.conditionValue}'
                    : badge.description,
                progress: earnedCodes.contains(badge.code) || badge.acquired
                    ? 1.0
                    : 0.0,
              ),
            )
            .where((badge) {
              return switch (_filterSelection) {
                '획득' => badge.acquired,
                '미획득' => !badge.acquired,
                _ => true,
              };
            })
            .toList(growable: false);
        final acquiredCount = allBadges
            .where((badge) => earnedCodes.contains(badge.code) || badge.acquired)
            .length;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
        Row(
          children: [
            Text('배지 갤러리', style: textTheme.titleLarge),
            const Spacer(),
            Text(
              '$acquiredCount/${allBadges.length} 획득',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
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
              onSelected: (_) => setState(() => _filterSelection = label),
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
          itemCount: badges.length,
          itemBuilder: (context, i) => _BadgeTile(
            badge: badges[i],
            onTap: () => _showBadgeBottomSheet(context, badges[i]),
          ),
        ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _GameErrorState(
        message: '배지를 불러오지 못했습니다',
        onRetry: () => ref.invalidate(badgesProvider),
      ),
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
              Icon(
                badge.icon,
                size: 48,
                color: badge.acquired ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                badge.acquired ? badge.name : '잠김',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '조건: ${badge.condition}',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
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
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${(badge.progress * 100).toInt()}%',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
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
                color: badge.acquired ? AppColors.surface2 : AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: badge.acquired
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                badge.icon,
                size: 32,
                color: badge.acquired ? AppColors.primary : AppColors.muted,
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
