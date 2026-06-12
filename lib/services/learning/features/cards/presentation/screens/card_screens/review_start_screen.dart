part of '../card_screens.dart';

// ── ReviewStartScreen — 복습 시작 화면 (SCR-W-CARD-005) ──

class ReviewStartScreen extends ConsumerWidget {
  const ReviewStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckId = ref.watch(selectedDeckIdProvider);
    final textTheme = Theme.of(context).textTheme;

    if (deckId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('덱을 선택해주세요', style: textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => context.go(AppRoutes.decks),
              child: const Text('덱 목록으로'),
            ),
          ],
        ),
      );
    }

    final decksAsync = ref.watch(deckListNotifierProvider);
    final countAsync = ref.watch(reviewQueueCountProvider(deckId));

    final decks = decksAsync.asData?.value ?? [];
    final deck = decks.where((Deck d) => d.id == deckId).isEmpty
        ? null
        : decks.firstWhere((Deck d) => d.id == deckId);

    return ConceptPage(
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              deck?.emoji ?? '📚',
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            deck?.name ?? '복습 시작',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (deck != null && deck.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              deck.description,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        countAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ConceptAiComment(text: '카드 수를 불러오지 못했어요: $e'),
          data: (count) => count == 0
              ? const ConceptAiComment(
                  text: '오늘 복습할 카드가 없어요! 내일 다시 확인해 보세요. 🎉',
                )
              : ConceptStatRow(
                  children: [
                    ConceptStat(
                      value: '$count',
                      label: '오늘 복습 카드',
                      color: AppColors.primary,
                    ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        const ConceptAiComment(
          text: '꾸준한 복습이 장기 기억으로 이어져요. 오늘도 화이팅! 💪',
        ),
        const SizedBox(height: AppSpacing.lg),
        countAsync.when(
          loading: () => const FilledButton(onPressed: null, child: Text('불러오는 중…')),
          error: (_, __) => const SizedBox.shrink(),
          data: (count) => count > 0
              ? FilledButton(
                  onPressed: () => context.go(AppRoutes.review),
                  child: Text('시작하기  ($count장)'),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () {
            ref.read(selectedDeckIdProvider.notifier).select(null);
            context.go(AppRoutes.decks);
          },
          child: const Text('돌아가기'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
