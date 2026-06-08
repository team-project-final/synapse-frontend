part of '../card_screens.dart';

// ── DeckListScreen (SCR-W-CARD-001) ──

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    // 1차 액션(새 덱)은 노트 화면과 동일하게 FAB로 분리, 헤더 우측엔 개수만.
    return Stack(
      children: [
        ConceptPage(
          children: [
            ConceptViewHead(title: '내 덱', meta: '총 ${_mockDecks.length}개'),
            const SizedBox(height: AppSpacing.sm),
            // Deck cards
            // TODO: 팀원 구현 — learning-svc 덱 목록 API 연동
            ConceptResponsiveGrid(
              isWide: isWide,
              children: [for (final deck in _mockDecks) _DeckCard(deck: deck)],
            ),
            // FAB에 마지막 카드가 가리지 않도록 하단 여백 확보.
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
          ],
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

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.deck});
  final _MockDeck deck;

  @override
  Widget build(BuildContext context) {
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
                // Mastery circular indicator
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: deck.progress,
                        strokeWidth: 4,
                        backgroundColor: AppColors.surface2,
                        color: AppColors.primary,
                      ),
                      Text(
                        '${(deck.progress * 100).toInt()}%',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 덱 설명(생성 시 입력한 설명 표시)
            if (deck.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                deck.description,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm + 2),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _CountChip(
                  label: '${deck.cardCount}장',
                  icon: Icons.style_outlined,
                  color: AppColors.muted,
                ),
                _CountChip(
                  label: '${deck.dueCount}개 복습 대기',
                  icon: Icons.schedule,
                  color: deck.dueCount > 10
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: deck.progress,
                minHeight: 7,
                backgroundColor: AppColors.surface2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.go(AppRoutes.review),
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
            // Sub-decks
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              // ListTile(ExpansionTile)이 ConceptCard의 배경 DecoratedBox 위에
              // 직접 그려지면 Flutter 3.44+ 가 assertion을 던지므로 투명 Material로 감싼다.
              child: Material(
                type: MaterialType.transparency,
                child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  '하위 덱',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                children: [
                  _SubDeckTile(
                    name: '${deck.name} - 기본',
                    count: deck.cardCount ~/ 2,
                  ),
                  _SubDeckTile(
                    name: '${deck.name} - 심화',
                    count: deck.cardCount - deck.cardCount ~/ 2,
                  ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubDeckTile extends StatelessWidget {
  const _SubDeckTile({required this.name, required this.count});
  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.folder_outlined,
        size: 18,
        color: AppColors.muted,
      ),
      title: Text(name, style: textTheme.bodySmall),
      trailing: Text(
        '$count장',
        style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
