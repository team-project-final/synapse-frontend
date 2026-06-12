part of '../card_screens.dart';

// ── ReviewScreen (FlipCard) ──

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  static const double _cardMaxWidth = 480;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckId = ref.read(selectedDeckIdProvider);
      if (deckId != null) {
        ref.read(reviewNotifierProvider.notifier).startSession(deckId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(reviewNotifierProvider);

    // 복습 완료 시 결과 화면으로 이동
    ref.listen(reviewNotifierProvider, (_, next) {
      if (next.isCompleted && mounted) {
        context.go(AppRoutes.reviewResult);
      }
    });

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.sessionId == null) {
      return Center(child: Text('오류: ${state.error}'));
    }

    final card = state.currentCard;
    final frontText = card?.frontContent ?? '카드를 불러오는 중…';
    final backText = card?.backContent ?? '';
    final current = state.reviewed + 1;
    final total = state.total;

    return Column(
      children: [
        // Progress row
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _cardMaxWidth + AppSpacing.lg * 2,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () {
                      ref.read(reviewNotifierProvider.notifier).reset();
                      context.go(AppRoutes.decks);
                    },
                    tooltip: '종료',
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: total > 0 ? state.reviewed / total : 0,
                        minHeight: 7,
                        backgroundColor: AppColors.surface2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    total > 0 ? '$current / $total' : '—',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Card area + rating buttons
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 260,
                      child: GestureDetector(
                        onHorizontalDragEnd: state.isSubmitting
                            ? null
                            : (details) {
                                final v = details.primaryVelocity ?? 0;
                                if (v.abs() < 300) return;
                                ref
                                    .read(reviewNotifierProvider.notifier)
                                    .submitRating(v < 0 ? 1 : 3);
                              },
                        child: FlipCard(
                          front: _FlashFace(
                            label: frontText,
                            hint: '👆 탭하여 정답 확인',
                          ),
                          back: _FlashFace(
                            label: backText,
                            highlighted: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Difficulty buttons (SM-2 rating)
                    Row(
                      children: [
                        _RateButton(
                          label: '다시',
                          sub: '<1분',
                          color: AppColors.error,
                          onTap: state.isSubmitting
                              ? null
                              : () => ref
                                  .read(reviewNotifierProvider.notifier)
                                  .submitRating(1),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _RateButton(
                          label: '어려움',
                          sub: '4일',
                          color: AppColors.warning,
                          onTap: state.isSubmitting
                              ? null
                              : () => ref
                                  .read(reviewNotifierProvider.notifier)
                                  .submitRating(2),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _RateButton(
                          label: '보통',
                          sub: '9일',
                          color: AppColors.success,
                          onTap: state.isSubmitting
                              ? null
                              : () => ref
                                  .read(reviewNotifierProvider.notifier)
                                  .submitRating(3),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _RateButton(
                          label: '쉬움',
                          sub: '21일',
                          color: AppColors.accent,
                          onTap: state.isSubmitting
                              ? null
                              : () => ref
                                  .read(reviewNotifierProvider.notifier)
                                  .submitRating(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlashFace extends StatelessWidget {
  const _FlashFace({required this.label, this.hint, this.highlighted = false});

  final String label;
  final String? hint;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.border,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                hint!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  const _RateButton({
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String sub;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
              child: Column(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
