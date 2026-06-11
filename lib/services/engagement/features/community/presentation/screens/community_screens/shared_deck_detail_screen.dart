part of '../community_screens.dart';

// ── SharedDeckDetailScreen (SCR-W-COMM-005) ──

class SharedDeckDetailScreen extends ConsumerStatefulWidget {
  const SharedDeckDetailScreen({
    required this.deckId,
    this.sharedContentId,
    this.shareToken,
    super.key,
  });

  final String deckId;
  final String? sharedContentId;
  final String? shareToken;

  @override
  ConsumerState<SharedDeckDetailScreen> createState() =>
      _SharedDeckDetailScreenState();
}

class _SharedDeckDetailScreenState
    extends ConsumerState<SharedDeckDetailScreen> {
  int _userRating = 0;
  // TODO: 팀원 구현 — 실제 소유자 여부로 교체. 데모용으로 공유 취소 노출.
  static const bool _isSharedByMe = true;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final hasShareParams =
        widget.sharedContentId != null && widget.shareToken != null;
    final cardsAsync = hasShareParams
        ? ref.watch(sharedDeckCardsProvider((
            deckId: widget.deckId,
            sharedContentId: widget.sharedContentId!,
            shareToken: widget.shareToken!,
          )))
        : null;

    return ConceptPage(
      children: [
        // Header
        Text('알고리즘 기초 100제', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              size: 14,
              color: AppColors.stone400,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '김알고',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.star, size: 14, color: AppColors.warning),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '4.5',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone500),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(
              Icons.download_outlined,
              size: 14,
              color: AppColors.stone400,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '234',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  AppToast.show(
                    context,
                    message: '덱이 내 라이브러리에 복사되었습니다',
                    type: ToastType.success,
                  );
                  // TODO: 팀원 구현 — 덱 복사 API 연동
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('복사하기'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () {
                ReportDialog.show(context, targetTitle: '알고리즘 기초 100제');
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('신고'),
            ),
          ],
        ),
        // 내가 공유한 콘텐츠면 공유 취소(삭제) 가능.
        if (_isSharedByMe) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: '공유 취소',
                content: '이 덱의 공유를 취소하면 그룹에서 더 이상 보이지 않습니다. 계속할까요?',
                confirmLabel: '공유 취소',
                isDestructive: true,
              );
              if (ok == true && context.mounted) {
                AppToast.show(
                  context,
                  message: '공유가 취소되었습니다',
                  type: ToastType.success,
                );
                // TODO: 팀원 구현 — 공유 취소(삭제) API 연동
              }
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('공유 취소'),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),

        // Card preview PageView carousel
        Text('카드 미리보기', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        _CardPreview(
          cardsAsync: cardsAsync,
          pageController: _pageController,
          textTheme: textTheme,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Rating section with interactive stars
        Text('평가', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        Row(
          children: List.generate(5, (i) {
            return Icon(
              i < 4 ? Icons.star : Icons.star_half,
              color: AppColors.warning,
              size: 28,
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '4.5 / 5.0 (42개 평가)',
          style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
        ),
        const SizedBox(height: AppSpacing.md),

        // User rating input
        Text('내 평가', style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => setState(() => _userRating = i + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Icon(
                  i < _userRating ? Icons.star : Icons.star_border,
                  color: i < _userRating
                      ? AppColors.warning
                      : AppColors.stone300,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        // TODO: 팀원 구현 — 별점 평가 기능 연동
      ],
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.cardsAsync,
    required this.pageController,
    required this.textTheme,
  });

  final AsyncValue<List<FlashCard>>? cardsAsync;
  final PageController pageController;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (cardsAsync == null) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            '공유 링크로 접근하면 카드 미리보기를 볼 수 있어요.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return cardsAsync!.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 80,
        child: Center(child: Text('카드를 불러오지 못했어요: $e')),
      ),
      data: (cards) => cards.isEmpty
          ? const SizedBox(
              height: 80,
              child: Center(child: Text('카드가 없습니다.')),
            )
          : SizedBox(
              height: 160,
              child: PageView.builder(
                controller: pageController,
                itemCount: cards.length,
                itemBuilder: (context, i) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.quiz_outlined,
                            color: AppColors.stone400,
                            size: 28,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            cards[i].frontContent,
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${i + 1} / ${cards.length}',
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.stone400),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
