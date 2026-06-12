import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/learning/features/cards/domain/entities/review_stats.dart';
import 'package:synapse_frontend/services/learning/features/cards/providers/cards_providers.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/home_board_section.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/planner_section.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DASH-001  DashboardScreen
// ═══════════════════════════════════════════════════════════════════════════

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 디자인 컨펌(2026-06-01): 홈 대시보드를 위젯보드화.
    // 플래너는 별도 사이드바 메뉴(/planner · PlannerScreen)로 분리.
    return const HomeBoardSection();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PlannerScreen — 사이드바 '플래너' 메뉴(/planner) 본문
//   캘린더(위) + 칸반(아래). AppShell 내부에서 렌더되는 BODY 화면.
// ═══════════════════════════════════════════════════════════════════════════

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlannerSection();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASH-002  DashboardHeatmapScreen
// ═══════════════════════════════════════════════════════════════════════════

class DashboardHeatmapScreen extends ConsumerStatefulWidget {
  const DashboardHeatmapScreen({super.key});

  @override
  ConsumerState<DashboardHeatmapScreen> createState() =>
      _DashboardHeatmapScreenState();
}

class _DashboardHeatmapScreenState
    extends ConsumerState<DashboardHeatmapScreen> {
  static const int _cols = 52;
  static const int _rows = 7;
  static const double _cellSize = 14;
  static const double _gap = 3;

  String? _selectedInfo;

  Color _colorForCount(int count) {
    if (count == 0) return AppColors.surface2;
    if (count <= 2) return const Color(0xFFD8C6F5);
    if (count <= 5) return const Color(0xFFB388F0);
    if (count <= 9) return const Color(0xFF8B5CF6);
    return AppColors.primary;
  }

  int? _hitTest(Offset local) {
    final col = local.dx ~/ (_cellSize + _gap);
    final row = local.dy ~/ (_cellSize + _gap);
    if (col < 0 || col >= _cols || row < 0 || row >= _rows) return null;
    return col * _rows + row;
  }

  // 오늘 기준 52주치 더미 weekly 데이터 (시연용, 실 데이터 없을 때)
  static const List<int> _dummyPattern = [
    0, 8, 15, 22, 31, 5, 18, 27, 12, 0, 24, 9, 17, 30, 6, 20, 14, 28, 3, 11,
    25, 8, 0, 19, 33, 7, 21, 16, 29, 4, 12, 26, 9, 18, 0, 23, 11, 28, 15, 7,
    30, 5, 22, 13, 27, 8, 20, 16, 31, 10, 24, 0,
  ];

  List<WeeklyHeatmapEntry> _buildDummyWeekly() {
    final now = DateTime.now();
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(52, (int i) {
      final weekStart = thisMonday.subtract(Duration(days: 7 * (51 - i)));
      return WeeklyHeatmapEntry(
        weekStart: weekStart,
        reviewCount: _dummyPattern[i % _dummyPattern.length],
        correctRate: 72.0 + (i % 5) * 4.5,
      );
    });
  }

  // 52×7 그리드 매핑 (전체 weekly 사용)
  List<int> _buildData(List<WeeklyHeatmapEntry> weekly) {
    final data = List.filled(_cols * _rows, 0);
    final recent = weekly.length > _cols ? weekly.sublist(weekly.length - _cols) : weekly;
    for (int wi = 0; wi < recent.length; wi++) {
      final col = _cols - recent.length + wi;
      final perDay = (recent[wi].reviewCount / 7).ceil();
      for (int row = 0; row < _rows; row++) {
        data[col * _rows + row] = perDay;
      }
    }
    return data;
  }

  String _infoForCol(int col, List<WeeklyHeatmapEntry> weekly) {
    final recent = weekly.length > _cols ? weekly.sublist(weekly.length - _cols) : weekly;
    final startCol = _cols - recent.length;
    if (col < startCol || col - startCol >= recent.length) return '데이터 없음';
    final entry = recent[col - startCol];
    final d = entry.weekStart;
    final ds = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return '$ds 주 — ${entry.reviewCount}회 복습';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const gridWidth = _cols * (_cellSize + _gap) - _gap;
    const gridHeight = _rows * (_cellSize + _gap) - _gap;

    final heatmapAsync = ref.watch(reviewStatsHeatmapProvider);
    final weekly = heatmapAsync.asData?.value.weekly ?? [];
    // 실 데이터 없으면 더미 데이터로 히트맵 표시
    final effectiveWeekly = weekly.isEmpty ? _buildDummyWeekly() : weekly;
    final data = _buildData(effectiveWeekly);

    return Scaffold(
      appBar: AppBar(title: const Text('학습 히트맵')),
      body: Column(
        children: [
          if (heatmapAsync.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (_selectedInfo != null) ...[
                  Card(
                    color: AppColors.stone50,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Text(
                        _selectedInfo!,
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GestureDetector(
                    onTapDown: (details) {
                      final index = _hitTest(details.localPosition);
                      if (index != null) {
                        setState(() {
                          _selectedInfo = _infoForCol(index ~/ _rows, effectiveWeekly);
                        });
                      }
                    },
                    child: CustomPaint(
                      size: const Size(gridWidth, gridHeight),
                      painter: _HeatmapFullPainter(data: data),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Legend ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('적음', style: textTheme.bodySmall),
                    const SizedBox(width: AppSpacing.xs),
                    for (final count in [0, 1, 4, 7, 12])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _colorForCount(count),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('많음', style: textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full heatmap painter ───────────────────────────────────────────────────

class _HeatmapFullPainter extends CustomPainter {
  _HeatmapFullPainter({required this.data});

  final List<int> data;

  static const int _cols = 52;
  static const int _rows = 7;
  static const double _cellSize = 14;
  static const double _gap = 3;

  Color _colorForCount(int count) {
    // 컨셉 보라 스케일 (적음→많음)
    if (count == 0) return AppColors.surface2;
    if (count <= 2) return const Color(0xFFD8C6F5);
    if (count <= 5) return const Color(0xFFB388F0);
    if (count <= 9) return const Color(0xFF8B5CF6);
    return AppColors.primary;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int col = 0; col < _cols; col++) {
      for (int row = 0; row < _rows; row++) {
        final index = col * _rows + row;
        final count = index < data.length ? data[index] : 0;
        final paint = Paint()..color = _colorForCount(count);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            col * (_cellSize + _gap),
            row * (_cellSize + _gap),
            _cellSize,
            _cellSize,
          ),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapFullPainter oldDelegate) =>
      oldDelegate.data != data;
}

// ═══════════════════════════════════════════════════════════════════════════
// DASH-003  DashboardStatsScreen
// ═══════════════════════════════════════════════════════════════════════════

class DashboardStatsScreen extends ConsumerStatefulWidget {
  const DashboardStatsScreen({super.key});

  @override
  ConsumerState<DashboardStatsScreen> createState() =>
      _DashboardStatsScreenState();
}

class _DashboardStatsScreenState extends ConsumerState<DashboardStatsScreen> {
  String _period = '주간';

  static const _kDayLabelsFallback = ['월', '화', '수', '목', '금', '토', '일'];

  int get _sliceCount {
    if (_period == '주간') return 7;
    if (_period == '월간') return 30;
    return 9999;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // ── overview (정확도 + 복습 수) ──
    final statsAsync = ref.watch(reviewStatsOverviewProvider);
    final daily = statsAsync.asData?.value.daily ?? [];
    final sliced = daily.length > _sliceCount ? daily.sublist(daily.length - _sliceCount) : daily;
    final hasOverview = sliced.isNotEmpty;
    final accuracyData = hasOverview
        ? sliced.map((d) => d.correctRate).toList()
        : const <double>[0.80, 0.75, 0.90, 0.85, 0.70, 0.88, 0.82];
    final reviewCountData = hasOverview
        ? sliced.map((d) => d.reviewCount.toDouble()).toList()
        : const <double>[12, 18, 8, 22, 15, 25, 20];
    final dayLabels = hasOverview
        ? sliced.map((d) => '${d.date.month}/${d.date.day}').toList()
        : _kDayLabelsFallback;
    final maxCount = reviewCountData.reduce((a, b) => a > b ? a : b);
    final maxY = maxCount < 10 ? 10.0 : (maxCount * 1.25).ceilToDouble();

    // ── retention ──
    final retentionAsync = ref.watch(reviewStatsRetentionProvider);
    final retentionPoints = retentionAsync.asData?.value.points ?? [];
    // 백엔드: index 0 = 오늘, 29 = 29일전 → 오래된 것부터 정렬 후 period만큼
    final sorted = retentionPoints.reversed.toList();
    final slicedRet = sorted.length > _sliceCount ? sorted.sublist(sorted.length - _sliceCount) : sorted;
    final hasRetention = slicedRet.isNotEmpty;
    final retentionData = hasRetention
        ? slicedRet.map((p) => p.retentionRate / 100.0).toList()
        : const <double>[0.95, 0.88, 0.82, 0.78, 0.75, 0.73, 0.71];
    final retentionLabels = hasRetention
        ? slicedRet.map((p) => '${p.date.month}/${p.date.day}').toList()
        : _kDayLabelsFallback;

    return Scaffold(
      appBar: AppBar(title: const Text('학습 통계 상세')),
      body: (statsAsync.isLoading || retentionAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // ── Period filter ──
                Center(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '주간', label: Text('주간')),
                      ButtonSegment(value: '월간', label: Text('월간')),
                      ButtonSegment(value: '전체', label: Text('전체')),
                    ],
                    selected: {_period},
                    onSelectionChanged: (selected) {
                      setState(() => _period = selected.first);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Retention curve (실데이터) ──
                Text('기억 유지율', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      height: 180,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _LineChartPainter(
                          values: retentionData,
                          labels: retentionLabels,
                          color: AppColors.primaryAmber,
                          maxY: 1.0,
                          formatY: (v) => '${(v * 100).toInt()}%',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Accuracy by day (실데이터) ──
                Text('일별 정답률', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      height: 180,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _BarChartPainter(
                          values: accuracyData,
                          labels: dayLabels,
                          color: AppColors.success,
                          maxY: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Daily review count (실데이터) ──
                Text('일별 복습 수', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      height: 180,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _LineChartPainter(
                          values: reviewCountData,
                          labels: dayLabels,
                          color: AppColors.info,
                          maxY: maxY,
                          formatY: (v) => '${v.toInt()}',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }
}

// ── Line chart painter ─────────────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.maxY,
    required this.formatY,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final double maxY;
  final String Function(double) formatY;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const leftPad = 40.0;
    const bottomPad = 24.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.stone200
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = chartH * (1 - i / 4);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: formatY(maxY * i / 4),
          style: const TextStyle(fontSize: 10, color: AppColors.stone400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Line + dots
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = color;

    final path = Path();
    final labelStep = (values.length / 7).ceil().clamp(1, values.length);
    for (int i = 0; i < values.length; i++) {
      // values.length == 1이면 분모가 0 → 가운데 고정
      final double x = values.length == 1
          ? leftPad + chartW / 2
          : leftPad + (chartW / (values.length - 1)) * i;
      final y = chartH * (1 - values[i] / maxY);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);

      // X label — 겹침 방지: 최대 7개만 표시
      if (i % labelStep == 0 || i == values.length - 1) {
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: const TextStyle(fontSize: 10, color: AppColors.stone400),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, chartH + 6));
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

// ── Bar chart painter ──────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.maxY,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const leftPad = 40.0;
    const bottomPad = 24.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.stone200
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = chartH * (1 - i / 4);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: '${(maxY * i / 4 * 100).toInt()}%',
          style: const TextStyle(fontSize: 10, color: AppColors.stone400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Bars
    final barWidth = chartW / values.length * 0.6;
    final spacing = chartW / values.length;
    final labelStep = (values.length / 7).ceil().clamp(1, values.length);

    for (int i = 0; i < values.length; i++) {
      final barH = chartH * (values[i] / maxY);
      final x = leftPad + spacing * i + (spacing - barWidth) / 2;
      final y = chartH - barH;
      final barPaint = Paint()..color = color.withAlpha(200);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barH),
          const Radius.circular(3),
        ),
        barPaint,
      );

      // X label — 겹침 방지: 최대 7개만 표시
      if (i % labelStep == 0 || i == values.length - 1) {
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: const TextStyle(fontSize: 10, color: AppColors.stone400),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(leftPad + spacing * i + (spacing - tp.width) / 2, chartH + 6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
