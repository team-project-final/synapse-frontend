part of '../card_screens.dart';

// ── ReviewResultScreen (SCR-W-CARD-006) ──

class ReviewResultScreen extends ConsumerWidget {
  const ReviewResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final reviewState = ref.watch(reviewNotifierProvider);
    final session = reviewState.completedSession;
    final results = reviewState.submittedResults;

    final reviewedCount = session?.reviewedCards ?? results.length;
    final accuracyPct = (reviewState.accuracy * 100).round();
    final xp = reviewState.earnedXp;

    // submittedResults와 queue를 매핑해서 카드 앞면 텍스트 + dueDate 구성
    final cardById = {for (final c in reviewState.queue) c.cardId: c};
    final nextReviews = results
        .where((r) => r.dueDate != null)
        .take(5)
        .map((r) => (front: cardById[r.cardId]?.frontContent ?? r.cardId, dueDate: r.dueDate!))
        .toList();

    return ConceptPage(
      children: [
        const SizedBox(height: AppSpacing.md),
        // 결과 orb
        const Center(
          child: SynapseOrb(
            size: 84,
            glyph: '🎉',
            glyphScale: 0.48,
            shadow: true,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            '복습 완료!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            '오늘 $reviewedCount장을 모두 끝냈어요',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Streak bar (mock — gamification 서비스 연동 전까지 고정값)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          decoration: BoxDecoration(
            color: AppColors.streak.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.streak.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '14일',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.streak,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '연속 학습 중!',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Stats
        ConceptStatRow(
          children: [
            ConceptStat(value: '+$xp', label: '획득 XP', color: AppColors.primary),
            ConceptStat(value: '$reviewedCount', label: '복습 카드'),
            ConceptStat(value: '$accuracyPct%', label: '정답률', color: AppColors.success),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // AI comment
        const ConceptAiComment(
          text: '오늘도 복습을 완료했어요! 꾸준히 하면 장기 기억으로 이어집니다. 🙌',
        ),
        // Accuracy donut chart
        const ConceptSectionLabel('정확도'),
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutChartPainter(
                correctRatio: reviewState.accuracy,
                correctColor: AppColors.primary,
                incorrectColor: AppColors.surface2,
              ),
              child: Center(
                child: Text(
                  '$accuracyPct%',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Next review schedule
        if (nextReviews.isNotEmpty) ...[
          const ConceptSectionLabel('다음 복습 예정'),
          ConceptCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < nextReviews.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule, size: 18, color: AppColors.muted),
                    title: Text(
                      nextReviews[i].front,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatDate(nextReviews[i].dueDate),
                      style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => context.go(AppRoutes.dashboard),
          child: const Text('대시보드로 이동'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.review),
          child: const Text('다시 시작'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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
