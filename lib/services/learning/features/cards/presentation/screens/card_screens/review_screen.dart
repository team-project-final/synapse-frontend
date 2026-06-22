part of '../card_screens.dart';

// ── ReviewScreen (FlipCard) ──

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({this.deckId, super.key});

  final String? deckId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  static const double _cardMaxWidth = 480;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void didUpdateWidget(covariant ReviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deckId != widget.deckId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  void _start() {
    if (!mounted) return;
    ref.read(reviewNotifierProvider.notifier).start(deckId: widget.deckId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewNotifierProvider);
    final card = state.currentCard;

    if (state.isLoading && state.session == null) {
      return const AppLoadingWidget(label: '복습 세션을 준비하고 있습니다.');
    }

    if (state.errorMessage != null && state.session == null) {
      return AppErrorWidget(message: state.errorMessage!, onRetry: _start);
    }

    if (state.hasNoDecks) {
      return AppEmptyState(
        icon: Icons.style_outlined,
        title: '복습할 덱이 없습니다.',
        body: '먼저 학습 덱을 만든 뒤 복습을 시작할 수 있습니다.',
        action: FilledButton.icon(
          onPressed: () => context.go(AppRoutes.decks),
          icon: const Icon(Icons.layers_outlined, size: 18),
          label: const Text('덱으로 이동'),
        ),
      );
    }

    if (state.hasNoDueCards || card == null) {
      return AppEmptyState(
        icon: Icons.check_circle_outline,
        title: '오늘 복습할 카드가 없습니다.',
        body: '선택한 덱의 복습 큐가 비어 있습니다.',
        action: OutlinedButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('새로고침'),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final total = state.totalCards;
    final current = state.currentIndex + 1;
    final progress = total == 0 ? 0.0 : current / total;

    return Column(
      children: [
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
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.go(AppRoutes.decks),
                    tooltip: '종료',
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: AppColors.surface2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '$current / $total',
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
                      height: 270,
                      child: FlipCard(
                        key: ValueKey(card.id),
                        front: _FlashFace(
                          label: card.frontContent,
                          hint: '탭하여 정답 확인',
                        ),
                        back: _FlashFace(
                          label: card.backContent,
                          highlighted: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ConceptCard(
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _ReviewMetaPill(
                            icon: Icons.layers_outlined,
                            label: state.selectedDeckName,
                          ),
                          _ReviewMetaPill(
                            icon: Icons.category_outlined,
                            label: card.typeLabel,
                          ),
                          _ReviewMetaPill(
                            icon: Icons.repeat,
                            label: '${card.repetitions}회 복습',
                          ),
                          _ReviewMetaPill(
                            icon: Icons.trending_up,
                            label:
                                'EF ${card.easinessFactor.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppErrorWidget(message: state.errorMessage!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _cardMaxWidth + AppSpacing.lg * 2,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  _RateButton(
                    label: '다시',
                    sub: '1',
                    color: AppColors.error,
                    onTap: state.isSubmitting ? null : () => _rate(1),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '어려움',
                    sub: '2',
                    color: AppColors.warning,
                    onTap: state.isSubmitting ? null : () => _rate(2),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '보통',
                    sub: '3',
                    color: AppColors.success,
                    onTap: state.isSubmitting ? null : () => _rate(3),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '쉬움',
                    sub: '4',
                    color: AppColors.accent,
                    onTap: state.isSubmitting ? null : () => _rate(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _rate(int rating) async {
    final startedAt = ref.read(reviewNotifierProvider).cardStartedAt;
    final completed = await ref
        .read(reviewNotifierProvider.notifier)
        .submitRating(rating, timeSpentMs: _timeSpentMs(startedAt));
    if (!mounted) return;
    if (completed) {
      context.go(AppRoutes.reviewResult);
    }
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.isEmpty ? '내용 없음' : label,
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
      ),
    );
  }
}

class _ReviewMetaPill extends StatelessWidget {
  const _ReviewMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    final enabled = onTap != null;
    return Expanded(
      child: Material(
        color: enabled ? color : color.withValues(alpha: 0.45),
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
    );
  }
}

int _timeSpentMs(DateTime? startedAt) {
  if (startedAt == null) return 0;
  return DateTime.now().difference(startedAt).inMilliseconds;
}
