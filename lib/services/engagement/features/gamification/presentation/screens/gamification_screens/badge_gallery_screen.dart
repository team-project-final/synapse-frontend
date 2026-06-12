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

    // TODO: 팀원 구현 — engagement-svc 배지 갤러리 API 연동
    const acquiredBadges = [
      _Badge(
        name: '첫 노트',
        icon: Icons.article_outlined,
        acquired: true,
        condition: '첫 번째 노트 작성',
        progress: 1.0,
      ),
      _Badge(
        name: '첫 복습',
        icon: Icons.refresh,
        acquired: true,
        condition: '첫 번째 복습 완료',
        progress: 1.0,
      ),
      _Badge(
        name: '7일 연속',
        icon: Icons.local_fire_department,
        acquired: true,
        condition: '7일 연속 학습',
        progress: 1.0,
      ),
      _Badge(
        name: '노트 마스터',
        icon: Icons.star,
        acquired: true,
        condition: '노트 50개 작성',
        progress: 1.0,
      ),
      _Badge(
        name: '지식 탐험가',
        icon: Icons.explore,
        acquired: true,
        condition: '레벨 7 달성',
        progress: 1.0,
      ),
      _Badge(
        name: 'AI 활용',
        icon: Icons.auto_awesome,
        acquired: true,
        condition: 'AI 카드 생성 10회',
        progress: 1.0,
      ),
    ];
    const lockedBadges = [
      _Badge(
        name: '30일 연속',
        icon: Icons.military_tech,
        acquired: false,
        condition: '30일 연속 학습',
        progress: 0.47,
      ),
      _Badge(
        name: '카드 100장',
        icon: Icons.style,
        acquired: false,
        condition: '카드 100장 생성',
        progress: 0.72,
      ),
      _Badge(
        name: '그룹 참여',
        icon: Icons.groups,
        acquired: false,
        condition: '그룹 3개 참여',
        progress: 0.33,
      ),
      _Badge(
        name: '공유 왕',
        icon: Icons.share,
        acquired: false,
        condition: '덱 5개 공유',
        progress: 0.2,
      ),
      _Badge(
        name: '레벨 10',
        icon: Icons.emoji_events,
        acquired: false,
        condition: '레벨 10 달성',
        progress: 0.7,
      ),
      _Badge(
        name: '1000 XP',
        icon: Icons.workspace_premium,
        acquired: false,
        condition: '1000 XP 달성',
        progress: 0.65,
      ),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            Text('배지 갤러리', style: textTheme.titleLarge),
            const Spacer(),
            Text(
              '12/30 획득',
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
          itemCount: filteredBadges.length,
          itemBuilder: (context, i) => _BadgeTile(
            badge: filteredBadges[i],
            onTap: () => _showBadgeBottomSheet(context, filteredBadges[i]),
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
