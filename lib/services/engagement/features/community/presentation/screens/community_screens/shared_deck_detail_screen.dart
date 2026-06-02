part of '../community_screens.dart';

// ── SharedDeckDetailScreen (SCR-W-COMM-005) ──

class SharedDeckDetailScreen extends ConsumerStatefulWidget {
  const SharedDeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<SharedDeckDetailScreen> createState() =>
      _SharedDeckDetailScreenState();
}

class _SharedDeckDetailScreenState
    extends ConsumerState<SharedDeckDetailScreen> {
  int _userRating = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — engagement-svc 공유 덱 상세 API 연동 (deckId: ${widget.deckId})
    const mockCards = [
      'Big O 표기법이란 무엇인가?',
      '재귀 알고리즘의 시간 복잡도 분석 방법은?',
      '동적 프로그래밍과 분할 정복의 차이점은?',
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        const SizedBox(height: AppSpacing.lg),

        // Card preview PageView carousel
        Text('카드 미리보기', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: mockCards.length,
            itemBuilder: (context, i) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
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
                        mockCards[i],
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${i + 1} / ${mockCards.length}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.stone400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
