part of '../study_board_kit.dart';

/// 목업 `.statgrid .s` — 3분할 통계 셀.
class StatCell {
  const StatCell({
    required this.value,
    required this.label,
    this.accent = false,
  });
  final String value;
  final String label;
  final bool accent;
}

/// 목업 `.statgrid` — 균등 분할 통계 그리드.
class StatGrid extends StatelessWidget {
  const StatGrid({required this.cells, super.key});

  final List<StatCell> cells;

  @override
  Widget build(BuildContext context) {
    // stretch + 세로 비제한 컨텍스트(ListView)에서 무한 높이 강제를 피하려고
    // IntrinsicHeight 로 행 높이를 자식 최대 높이에 맞춰 제한한다.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatCellView(cell: cells[i])),
          ],
        ],
      ),
    );
  }
}

class _StatCellView extends StatelessWidget {
  const _StatCellView({required this.cell});

  final StatCell cell;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Text(
              cell.value,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                color: cell.accent ? AppColors.primary : AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            cell.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// XP progress bar using Warm Amber.
class XpBar extends StatelessWidget {
  const XpBar({required this.progress, this.height = 9, super.key});

  /// 0.0 ~ 1.0.
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: height,
        color: AppColors.surface2,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clamped,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryHover],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 복습 SRS 평가 4버튼의 한 칸 사양.
class RateOption {
  const RateOption({
    required this.label,
    required this.interval,
    required this.color,
  });
  final String label;

  /// 다음 복습 간격(예: '<1분', '4일').
  final String interval;
  final Color color;
}

/// 목업 `.rate` — 복습 4단계 평가 버튼(라벨 + 간격).
/// 기본 4칸: 다시/어려움/보통/쉬움(danger/warning/success/accent).
class RateButtons extends StatelessWidget {
  const RateButtons({required this.onRate, this.options, super.key});

  /// 인덱스(0=다시 … 3=쉬움)로 콜백.
  final ValueChanged<int> onRate;
  final List<RateOption>? options;

  static const _defaults = [
    RateOption(label: '다시', interval: '<1분', color: AppColors.error),
    RateOption(label: '어려움', interval: '4일', color: AppColors.streak),
    RateOption(label: '보통', interval: '9일', color: AppColors.success),
    RateOption(label: '쉬움', interval: '21일', color: AppColors.accent),
  ];

  @override
  Widget build(BuildContext context) {
    final opts = options ?? _defaults;
    return Row(
      children: [
        for (var i = 0; i < opts.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Material(
              color: opts[i].color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () => onRate(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opts[i].label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        opts[i].interval,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
