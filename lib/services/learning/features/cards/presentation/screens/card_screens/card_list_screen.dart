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
  final Set<int> _checkedCards = {};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sortOptions = ['최신순', '난이도순', '복습순'];

    // TODO: 팀원 구현 — learning-svc 카드 목록 API 연동 (deckId: ${widget.deckId})
    final mockCards = [
      {
        'front': 'L1 정규화와 L2 정규화의 차이점은?',
        'back': 'L1은 절댓값 합(Lasso), L2는 제곱합(Ridge). L1은 희소성 유도.',
        'type': 'Basic',
      },
      {
        'front': '동적 프로그래밍의 두 가지 접근법은?',
        'back': '탑다운(메모이제이션)과 바텀업(타뷸레이션)',
        'type': 'Basic',
      },
      {
        'front': 'Big O 표기법에서 O(n log n)의 의미는?',
        'back': '병합 정렬, 힙 정렬 등의 시간 복잡도. 선형로그 복잡도.',
        'type': 'Cloze',
      },
      {
        'front': 'AWS S3 버킷 정책과 IAM 정책의 차이?',
        'back': 'S3 버킷 정책은 리소스 기반, IAM은 사용자/역할 기반 정책',
        'type': 'Basic',
      },
    ];

    return Stack(
      children: [
        // 헤더(제목·검색·필터)는 고정하고 카드 목록만 Sliver로 스크롤한다.
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
                      const ConceptViewHead(title: '카드', meta: '카드 4'),
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
                      // Sort pills
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
                      // Type filter pills
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          for (final type in ['전체', 'Basic', 'Cloze'])
                            ConceptFilterPill(
                              label: type,
                              selected: _selectedType == type,
                              onTap: () => setState(() => _selectedType = type),
                            ),
                        ],
                      ),
                      if (_checkedCards.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.icon(
                            onPressed: () {
                              // TODO: 팀원 구현 — 선택 카드 삭제 API 연동
                              setState(() => _checkedCards.clear());
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text('선택 삭제 (${_checkedCards.length})'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                      const ConceptSectionLabel('카드 목록', topGap: AppSpacing.md),
                    ],
                  ),
                ),
                // ── 카드 목록만 스크롤 (Sliver) ──
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          AppSpacing.xxl + AppSpacing.xxl,
                        ),
                        sliver: SliverList.builder(
                          itemCount: mockCards.length,
                          itemBuilder: (context, index) {
                            final card = mockCards[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: ConceptCard(
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _checkedCards.contains(index),
                                      onChanged: (v) {
                                        setState(() {
                                          if (v == true) {
                                            _checkedCards.add(index);
                                          } else {
                                            _checkedCards.remove(index);
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
                                              ConceptTag(
                                                card['type']!.toLowerCase(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            card['front']!,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.xxs,
                                          ),
                                          Text(
                                            card['back']!,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: AppColors.muted,
                                                ),
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
                                      onPressed: () =>
                                          context.go(AppRoutes.cardNew),
                                      // TODO: 팀원 구현 — 카드 편집 화면 연동
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 직접 카드 작성(주)
              FloatingActionButton.extended(
                heroTag: 'newCardFab',
                onPressed: () =>
                    context.go(AppRoutes.deckCardNewPath(widget.deckId)),
                icon: const Icon(Icons.add),
                label: const Text('새 카드'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
