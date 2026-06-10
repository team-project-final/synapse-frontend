part of '../community_screens.dart';

// ── SharedDecksScreen (SCR-W-COMM-004) ──

class SharedDecksScreen extends ConsumerStatefulWidget {
  const SharedDecksScreen({super.key});

  @override
  ConsumerState<SharedDecksScreen> createState() => _SharedDecksScreenState();
}

class _SharedDecksScreenState extends ConsumerState<SharedDecksScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = '전체';
  String _selectedCategory = '전체';
  String _selectedDifficulty = '전체';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['전체', '최근', '인기', '내 그룹'];
    final categories = ['전체', '프로그래밍', '데이터', '클라우드', '디자인'];
    final difficulties = ['전체', '입문', '중급', '고급'];
    final query = SharedContentQuery(
      query: _searchController.text,
      contentType: SharedContentType.deck,
    );
    final decksAsync = ref.watch(sharedContentsProvider(query));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: StudySearchBar(
            hint: '공유 덱 검색…',
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: filters.map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: StudyPill(
                  label: f,
                  selected: _selectedFilter == f,
                  onTap: () => setState(() => _selectedFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Category and difficulty filter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              ...categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: StudyPill(
                    label: c,
                    selected: _selectedCategory == c,
                    onTap: () => setState(() => _selectedCategory = c),
                  ),
                );
              }),
              Container(
                width: 1,
                height: 24,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              ...difficulties.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: StudyPill(
                    label: d,
                    selected: _selectedDifficulty == d,
                    onTap: () => setState(() => _selectedDifficulty = d),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: decksAsync.when(
            data: (decks) => decks.isEmpty
                ? const _EmptyGroupList(message: '공유 덱이 없습니다')
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: decks.length,
                    itemBuilder: (context, i) =>
                        _SharedDeckCard(deck: decks[i]),
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
            error: (_, _) => _ErrorState(
              message: '공유 덱을 불러오지 못했습니다',
              onRetry: () => ref.invalidate(sharedContentsProvider(query)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SharedDeckCard extends ConsumerStatefulWidget {
  const _SharedDeckCard({required this.deck});
  final SharedContent deck;

  @override
  ConsumerState<_SharedDeckCard> createState() => _SharedDeckCardState();
}

class _SharedDeckCardState extends ConsumerState<_SharedDeckCard> {
  bool _copying = false;

  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () =>
            context.go(AppRoutes.communitySharedDeckDetailPath(deck.shareToken)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.style_outlined,
                size: 32,
                color: AppColors.primaryAmber,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                deck.title,
                style: textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'User ${deck.ownerId}',
                style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
              ),
              const Spacer(),
              // Star rating row
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < 4 ? Icons.star : Icons.star_border,
                    size: 14,
                    color: i < 4
                        ? AppColors.warning
                        : AppColors.stone300,
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Text(
                    '4.0',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.download_outlined,
                    size: 14,
                    color: AppColors.stone400,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${deck.downloadCount}회',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _copying
                      ? null
                      : () async {
                          setState(() => _copying = true);
                          try {
                            await ref
                                .read(communityApiProvider)
                                .forkSharedContent(deck.shareToken);
                            ref.invalidate(
                              sharedContentProvider(deck.shareToken),
                            );
                            if (context.mounted) {
                              AppToast.show(
                                context,
                                message: '덱이 내 라이브러리에 복사되었습니다',
                                type: ToastType.success,
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              AppToast.show(
                                context,
                                message: '덱 복사에 실패했습니다',
                                type: ToastType.error,
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _copying = false);
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: _copying
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('복사하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
