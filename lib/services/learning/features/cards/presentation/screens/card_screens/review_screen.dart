part of '../card_screens.dart';

// ── ReviewScreen (FlipCard) ──

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  // v1 ⑥: 진행 7/18, 단계별 AI 힌트(1→2단계).
  static const _current = 7;
  static const _total = 18;

  // 진행바·카드·평점 버튼을 동일 폭으로 중앙 정렬(웹 넓은 폭에서 정렬 흐트러짐 방지).
  static const double _cardMaxWidth = 480;

  // TODO: 팀원 구현 — learning-svc 단계별 AI 힌트 API 연동
  static const _hints = [
    '힌트: 모델이 학습 데이터를 "외워버린" 상황을 떠올려 보세요. 새로운 데이터에서는 어떻게 될까요?',
    '힌트 2: 학습 데이터의 정답률은 매우 높지만, 처음 보는 검증 데이터에서는 정답률이 떨어지는 현상이에요.',
  ];

  int _hintLevel = 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Progress row — 카드와 동일 폭(480)으로 중앙 정렬
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
                    onPressed: () => context.go(AppRoutes.decks),
                    tooltip: '종료',
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: const LinearProgressIndicator(
                        value: _current / _total,
                        minHeight: 7,
                        backgroundColor: AppColors.surface2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '$_current / $_total',
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

        // Card area
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 260,
                      child: FlipCard(
                        front: _FlashFace(
                          label: '과적합이란 무엇인가?',
                          hint: '👆 탭하여 정답 확인',
                        ),
                        back: _FlashFace(
                          label: '학습 데이터에는 잘 맞지만 새 데이터에 일반화하지 못하는 현상.',
                          highlighted: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 단계별 AI 힌트
                    for (int i = 0; i < _hintLevel; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      ConceptAiComment(text: _hints[i]),
                    ],
                    if (_hintLevel < _hints.length) ...[
                      const SizedBox(height: AppSpacing.md),
                      _HintButton(onTap: () => setState(() => _hintLevel++)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Difficulty buttons (SM-2 rating) — 카드와 동일 폭(480)으로 중앙 정렬
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
                    sub: '<1분',
                    color: AppColors.error,
                    onTap: () {
                      // TODO: 팀원 구현 — SM-2 rating API 호출
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '어려움',
                    sub: '4일',
                    color: AppColors.warning,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '보통',
                    sub: '9일',
                    color: AppColors.success,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '쉬움',
                    sub: '21일',
                    color: AppColors.accent,
                    onTap: () {},
                  ),
                ],
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
            // TODO: 팀원 구현 — learning-svc 카드 데이터 연동
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}

/// "💡 한 단계 더 힌트 받기" 버튼. v1 목업 `.hintbtn` — surface2 배경 +
/// primary 점선 보더 + primary 텍스트.
class _HintButton extends StatelessWidget {
  const _HintButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: DottedBorderBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 3),
            child: Center(
              child: Text(
                '💡 한 단계 더 힌트 받기',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// primary 점선 테두리 박스 (CustomPaint). Flutter 기본 Border는 점선을
/// 지원하지 않으므로 직접 그린다.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.primary,
        radius: AppRadius.sm,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
