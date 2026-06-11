part of '../card_screens.dart';

// ── DeckListScreen (SCR-W-CARD-001) ──

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final decksAsync = ref.watch(deckListNotifierProvider);

    return Stack(
      children: [
        decksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('오류: $e')),
          data: (decks) => ConceptPage(
            children: [
              ConceptViewHead(title: '내 덱', meta: '총 ${decks.length}개'),
              const SizedBox(height: AppSpacing.sm),
              ConceptResponsiveGrid(
                isWide: isWide,
                children: [for (final deck in decks) _DeckCard(deck: deck)],
              ),
              const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
            ],
          ),
        ),
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'ai_cards_fab',
                onPressed: () => context.go(AppRoutes.aiCards),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI 카드 생성'),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryFg,
              ),
              const SizedBox(height: AppSpacing.sm),
              FloatingActionButton.extended(
                heroTag: 'new_deck_fab',
                onPressed: () => context.go(AppRoutes.deckNew),
                icon: const Icon(Icons.add),
                label: const Text('새 덱'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeckCard extends ConsumerWidget {
  const _DeckCard({required this.deck});
  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ConceptCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(deck.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    deck.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (deck.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                deck.description,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(selectedDeckIdProvider.notifier).select(deck.id);
                      context.go(AppRoutes.reviewStart);
                    },
                    child: const Text('복습 시작'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.go(AppRoutes.deckCardsPath(deck.id)),
                    child: const Text('카드 보기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
