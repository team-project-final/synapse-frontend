part of '../card_screens.dart';

// ── ReviewResultScreen (SCR-W-CARD-006) ──

class ReviewResultScreen extends ConsumerWidget {
  const ReviewResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewNotifierProvider);
    final textTheme = Theme.of(context).textTheme;

    if (!state.isCompleted) {
      return ConceptPage(
        children: [
          AppEmptyState(
            icon: Icons.fact_check_outlined,
            title: '복습 결과가 없습니다.',
            body: '완료된 복습 세션이 있으면 결과가 표시됩니다.',
            action: FilledButton.icon(
              onPressed: () => context.go(AppRoutes.review),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('복습 시작'),
            ),
          ),
        ],
      );
    }

    final accuracyPercent = (state.accuracy * 100).round();
    final scheduleItems = _scheduleItems(state);

    return ConceptPage(
      children: [
        const SizedBox(height: AppSpacing.md),
        const Center(
          child: SynapseOrb(
            size: 84,
            glyph: '✓',
            glyphScale: 0.48,
            shadow: true,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            '복습 완료',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            '${state.reviewedCards}장을 처리했습니다.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ConceptStatRow(
          children: [
            ConceptStat(value: '${state.reviewedCards}', label: '복습 카드'),
            ConceptStat(
              value: '$accuracyPercent%',
              label: '기억 성공',
              color: AppColors.success,
            ),
            ConceptStat(
              value: _formatDuration(state.elapsedMs),
              label: '소요 시간',
            ),
          ],
        ),
        const ConceptSectionLabel('정확도'),
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutChartPainter(
                correctRatio: state.accuracy,
                correctColor: AppColors.primary,
                incorrectColor: AppColors.surface2,
              ),
              child: Center(
                child: Text(
                  '$accuracyPercent%',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (scheduleItems.isNotEmpty) ...[
          const ConceptSectionLabel('다음 복습 예정'),
          ConceptCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < scheduleItems.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ReviewScheduleTile(item: scheduleItems[i]),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.dashboard),
          icon: const Icon(Icons.dashboard_outlined, size: 18),
          label: const Text('대시보드로 이동'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.review),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('다시 시작'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _ReviewScheduleTile extends StatelessWidget {
  const _ReviewScheduleTile({required this.item});

  final _ReviewScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: const Icon(Icons.schedule, size: 18, color: AppColors.muted),
      title: Text(
        item.title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        item.ratingLabel,
        style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
      ),
      trailing: Text(
        _formatDate(item.dueDate),
        style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
      ),
    );
  }
}

class _ReviewScheduleItem {
  const _ReviewScheduleItem({
    required this.title,
    required this.ratingLabel,
    this.dueDate,
  });

  final String title;
  final String ratingLabel;
  final DateTime? dueDate;
}

List<_ReviewScheduleItem> _scheduleItems(ReviewState state) {
  return state.results
      .map((result) {
        final card = state.cards
            .where((card) => card.id == result.cardId)
            .firstOrNull;
        return _ReviewScheduleItem(
          title: card?.frontContent ?? result.cardId,
          ratingLabel:
              '${_ratingLabel(result.rating)} · ${result.newIntervalDays}일 후',
          dueDate: result.dueDate,
        );
      })
      .toList(growable: false);
}

String _ratingLabel(int rating) {
  return switch (rating) {
    1 => '다시',
    2 => '어려움',
    3 => '보통',
    4 => '쉬움',
    _ => '평가 없음',
  };
}

String _formatDate(DateTime? value) {
  if (value == null) return '일정 미정';
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

String _formatDuration(int elapsedMs) {
  if (elapsedMs <= 0) return '0초';
  final duration = Duration(milliseconds: elapsedMs);
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  if (minutes == 0) return '$seconds초';
  return '$minutes분 ${seconds.toString().padLeft(2, '0')}초';
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.correctRatio,
    required this.correctColor,
    required this.incorrectColor,
  });

  final double correctRatio;
  final Color correctColor;
  final Color incorrectColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const strokeWidth = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    paint.color = incorrectColor;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 2 * math.pi, false, paint);

    paint.color = correctColor;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * correctRatio,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.correctRatio != correctRatio;
}
