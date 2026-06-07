part of '../card_screens.dart';

// ── ReviewResultScreen (SCR-W-CARD-006) ──

class ReviewResultScreen extends ConsumerWidget {
  const ReviewResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — learning-svc 세션 결과 데이터 연동
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
            '오늘 25장을 모두 끝냈어요',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Streak bar
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
        const ConceptStatRow(
          children: [
            ConceptStat(value: '+85', label: '획득 XP', color: AppColors.primary),
            ConceptStat(value: '25', label: '복습 카드'),
            ConceptStat(value: '80%', label: '정답률', color: AppColors.success),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // AI comment
        const ConceptAiComment(
          text:
              '정답률이 지난주보다 6%p 올랐어요! 다만 「과적합」 관련 카드에서 막혔으니, 내일은 그 노트를 한 번 더 보면 좋겠어요. 🙌',
        ),
        // Accuracy donut chart
        const ConceptSectionLabel('정확도'),
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutChartPainter(
                correctRatio: 0.78,
                correctColor: AppColors.primary,
                incorrectColor: AppColors.surface2,
              ),
              child: Center(
                child: Text(
                  '78%',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Next review schedule
        const ConceptSectionLabel('다음 복습 예정'),
        ConceptCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < _kNextReviews.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.schedule,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  title: Text(
                    _kNextReviews[i]['title']!,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    _kNextReviews[i]['date']!,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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

const _kNextReviews = [
  {'title': 'L1 정규화란?', 'date': '2026-05-22'},
  {'title': '동적 프로그래밍 정의', 'date': '2026-05-23'},
  {'title': 'AWS S3 버킷 정책 차이', 'date': '2026-05-25'},
];

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
