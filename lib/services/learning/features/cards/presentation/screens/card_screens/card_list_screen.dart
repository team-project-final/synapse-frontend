part of '../card_screens.dart';

// ── CardListScreen (SCR-W-CARD-002) ──

class CardListScreen extends ConsumerStatefulWidget {
  const CardListScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends ConsumerState<CardListScreen> {
  String _selectedSort = '최신순';
  String _selectedType = '전체';
  final Set<String> _checkedCardIds = {};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sortOptions = ['최신순', '난이도순', '복습순'];
    final cardsAsync = ref.watch(cardListProvider(widget.deckId));

    return Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 고정 헤더 ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConceptViewHead(
                        title: '카드',
                        meta: cardsAsync.asData != null
                            ? '카드 ${cardsAsync.asData!.value.length}'
                            : '카드',
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () =>
                              ShareDialog.show(context, targetTitle: '내 덱'),
                          icon: const Icon(Icons.ios_share, size: 18),
                          label: const Text('공유하기'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ConceptSearchBar(hint: '카드 검색…', onTap: () {}),
                      const SizedBox(height: AppSpacing.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final s in sortOptions) ...[
                              ConceptFilterPill(
                                label: s,
                                selected: _selectedSort == s,
                                onTap: () => setState(() => _selectedSort = s),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          for (final type in ['전체', 'BASIC', 'CLOZE'])
                            ConceptFilterPill(
                              label: type,
                              selected: _selectedType == type,
                              onTap: () =>
                                  setState(() => _selectedType = type),
                            ),
                        ],
                      ),
                      if (_checkedCardIds.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.icon(
                            onPressed: () async {
                              for (final cardId in _checkedCardIds) {
                                await ref
                                    .read(deleteCardUseCaseProvider)
                                    .call(widget.deckId, cardId);
                              }
                              setState(() => _checkedCardIds.clear());
                              ref.invalidate(
                                  cardListProvider(widget.deckId));
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label:
                                Text('선택 삭제 (${_checkedCardIds.length})'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                      const ConceptSectionLabel('카드 목록',
                          topGap: AppSpacing.md),
                    ],
                  ),
                ),
                // ── 카드 목록 (Sliver) ──
                Expanded(
                  child: cardsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('오류: $e')),
                    data: (cards) {
                      final filtered = _selectedType == '전체'
                          ? cards
                          : cards
                              .where((c) =>
                                  c.cardType.toUpperCase() == _selectedType)
                              .toList();
                      return CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.sm,
                              AppSpacing.lg,
                              AppSpacing.xxl + AppSpacing.xxl,
                            ),
                            sliver: SliverList.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final card = filtered[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.sm),
                                  child: ConceptCard(
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _checkedCardIds
                                              .contains(card.id),
                                          onChanged: (v) {
                                            setState(() {
                                              if (v == true) {
                                                _checkedCardIds.add(card.id);
                                              } else {
                                                _checkedCardIds
                                                    .remove(card.id);
                                              }
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  ConceptTag(card.cardType
                                                      .toLowerCase()),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xs),
                                              Text(
                                                card.frontContent,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700),
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xxs),
                                              Text(
                                                card.backContent,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                        color: AppColors.muted),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: AppColors.muted,
                                            size: 20,
                                          ),
                                          onPressed: () => context.go(
                                              AppRoutes.deckCardEditPath(
                                                  widget.deckId, card.id)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: FloatingActionButton.extended(
            heroTag: 'newCardFab',
            onPressed: () =>
                context.go(AppRoutes.deckCardNewPath(widget.deckId)),
            icon: const Icon(Icons.add),
            label: const Text('새 카드'),
          ),
        ),
      ],
    );
  }
}
