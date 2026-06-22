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
    final badgesValue = ref.watch(gamificationBadgeGalleryProvider);

    return AppAsyncValueWidget<List<GamificationBadge>>(
      value: badgesValue,
      loading: const AppLoadingWidget(label: '배지 목록을 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '배지 목록을 불러오지 못했습니다.',
        onRetry: () => ref.invalidate(gamificationBadgeGalleryProvider),
      ),
      isEmpty: (badges) => badges.isEmpty,
      empty: const AppEmptyState(
        icon: Icons.workspace_premium_outlined,
        title: '표시할 배지가 없습니다.',
      ),
      data: (badges) => _buildGallery(context, badges),
    );
  }

  Widget _buildGallery(BuildContext context, List<GamificationBadge> badges) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final acquiredCount = badges.where((badge) => badge.earned).length;

    final filteredBadges = switch (_filterSelection) {
      '획득' => badges.where((badge) => badge.earned).toList(growable: false),
      '미획득' => badges.where((badge) => !badge.earned).toList(growable: false),
      _ => badges,
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            Text('배지 갤러리', style: textTheme.titleLarge),
            const Spacer(),
            Text(
              '$acquiredCount/${badges.length} 획득',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
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
        if (filteredBadges.isEmpty)
          const AppEmptyState(
            icon: Icons.workspace_premium_outlined,
            title: '조건에 맞는 배지가 없습니다.',
          )
        else
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
              onTap: () => _showBadgeBottomSheet(context, filteredBadges[i]),
            ),
          ),
      ],
    );
  }

  void _showBadgeBottomSheet(BuildContext context, GamificationBadge badge) {
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
                Icons.workspace_premium,
                size: 48,
                color: badge.earned ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                badge.earned ? badge.name : '잠김',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                badge.description.isEmpty
                    ? badge.conditionLabel
                    : badge.description,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '조건: ${badge.conditionLabel}',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, this.onTap});
  final GamificationBadge badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: badge.earned ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: badge.earned ? AppColors.surface2 : AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: badge.earned
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 32,
                color: badge.earned ? AppColors.primary : AppColors.muted,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              badge.earned ? badge.name : '잠김',
              style: textTheme.bodySmall?.copyWith(
                color: badge.earned ? null : AppColors.muted,
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
