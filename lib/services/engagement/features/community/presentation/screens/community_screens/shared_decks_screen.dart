part of '../community_screens.dart';

// ── SharedDecksScreen (SCR-W-COMM-004) ──

class SharedDecksScreen extends ConsumerStatefulWidget {
  const SharedDecksScreen({super.key});

  @override
  ConsumerState<SharedDecksScreen> createState() => _SharedDecksScreenState();
}

class _SharedDecksScreenState extends ConsumerState<SharedDecksScreen> {
  final _searchController = TextEditingController();
  SharedContentSort _sortOrder = SharedContentSort.recent;
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = SharedContentQuery(
      contentType: 'DECK',
      searchText: _searchText,
      sortOrder: _sortOrder,
    );
    final decksValue = ref.watch(sharedContentSearchProvider(query));

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
            onChanged: (value) => setState(() => _searchText = value.trim()),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: SharedContentSort.values.map((sort) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: StudyPill(
                  label: sort.label,
                  selected: _sortOrder == sort,
                  onTap: () => setState(() => _sortOrder = sort),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: AppAsyncValueWidget<List<SharedContent>>(
            value: decksValue,
            loading: const AppLoadingWidget(label: '공유 덱을 불러오는 중입니다.'),
            error: (error, _) => AppErrorWidget(
              message: '공유 덱을 불러오지 못했습니다.',
              onRetry: () => ref.invalidate(sharedContentSearchProvider(query)),
            ),
            isEmpty: (items) => items.isEmpty,
            empty: const AppEmptyState(
              icon: Icons.style_outlined,
              title: '공유된 덱이 없습니다.',
            ),
            data: (decks) => LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;
                final crossAxisCount = isNarrow
                    ? 1
                    : (constraints.maxWidth / 220).floor().clamp(2, 4);
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: isNarrow ? 1.25 : 0.72,
                  ),
                  itemCount: decks.length,
                  itemBuilder: (context, i) =>
                      _SharedDeckCard(deck: decks[i], query: query),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SharedDeckCard extends ConsumerStatefulWidget {
  const _SharedDeckCard({required this.deck, required this.query});

  final SharedContent deck;
  final SharedContentQuery query;

  @override
  ConsumerState<_SharedDeckCard> createState() => _SharedDeckCardState();
}

class _SharedDeckCardState extends ConsumerState<_SharedDeckCard> {
  bool _copying = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final deck = widget.deck;

    return Card(
      child: InkWell(
        onTap: () => context.go(
          AppRoutes.communitySharedDeckDetailPath(deck.shareToken),
        ),
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
                deck.ownerLabel,
                style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
              ),
              if (deck.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  deck.description,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.stone500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.download_outlined,
                        size: 14,
                        color: AppColors.stone400,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        '${_formatCount(deck.downloadCount)}회',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.stone400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    deck.createdLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _copying ? null : _forkDeck,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: _copying
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('복사하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _forkDeck() async {
    setState(() => _copying = true);
    try {
      await ref
          .read(engagementApiProvider)
          .forkSharedContent(widget.deck.shareToken);
      ref.invalidate(sharedContentSearchProvider(widget.query));
      if (mounted) {
        AppToast.show(
          context,
          message: '덱이 내 라이브러리에 복사되었습니다',
          type: ToastType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, message: '덱을 복사하지 못했습니다', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }
}
