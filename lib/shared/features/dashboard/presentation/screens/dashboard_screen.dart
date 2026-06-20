import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/home_board_section.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/planner_section.dart';

// ── Mock data ──────────────────────────────────────────────────────────────

List<int> _generateHeatmapData(int days) {
  final rng = math.Random(42);
  return List.generate(days, (_) {
    final roll = rng.nextDouble();
    if (roll < 0.3) return 0;
    if (roll < 0.55) return rng.nextInt(2) + 1;
    if (roll < 0.8) return rng.nextInt(3) + 3;
    if (roll < 0.95) return rng.nextInt(4) + 6;
    return rng.nextInt(6) + 10;
  });
}

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

  late final List<int> _data;
  String? _selectedInfo;

  @override
  void initState() {
    super.initState();
    // TODO: 팀원 구현 — learning-svc 학습 히트맵 데이터 연동
    _data = _generateHeatmapData(_cols * _rows);
  }

  Color _colorForCount(int count) {
    // 컨셉 보라 스케일 (적음→많음)
    if (count == 0) return AppColors.surface2;
    if (count <= 2) return AppColors.primaryLight;
    if (count <= 5) return AppColors.primary.withValues(alpha: 0.42);
    if (count <= 9) return AppColors.primary.withValues(alpha: 0.68);
    return AppColors.primary;
  }

  int? _hitTest(Offset local) {
    final col = local.dx ~/ (_cellSize + _gap);
    final row = local.dy ~/ (_cellSize + _gap);
    if (col < 0 || col >= _cols || row < 0 || row >= _rows) return null;
    final index = col * _rows + row;
    if (index >= _data.length) return null;
    return index;
  }

  String _dateForIndex(int index) {
    final today = DateTime.now();
    const totalDays = _cols * _rows;
    final daysAgo = totalDays - 1 - index;
    final date = today.subtract(Duration(days: daysAgo));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const gridWidth = _cols * (_cellSize + _gap) - _gap;
    const gridHeight = _rows * (_cellSize + _gap) - _gap;

    return Scaffold(
      appBar: AppBar(title: const Text('학습 히트맵')),
      body: ListView(
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
                    final date = _dateForIndex(index);
                    final count = _data[index];
                    _selectedInfo = '$date — $count회 학습';
                  });
                }
              },
              child: CustomPaint(
                size: const Size(gridWidth, gridHeight),
                painter: _HeatmapFullPainter(data: _data),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
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
    if (count <= 2) return AppColors.primaryLight;
    if (count <= 5) return AppColors.primary.withValues(alpha: 0.42);
    if (count <= 9) return AppColors.primary.withValues(alpha: 0.68);
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

  // TODO: 팀원 구현 — learning-svc 학습 통계 데이터 연동
  static const _kRetentionData = [0.95, 0.88, 0.82, 0.78, 0.75, 0.73, 0.71];
  static const _kAccuracyByDay = [0.80, 0.75, 0.90, 0.85, 0.70, 0.88, 0.82];
  static const _kStudyTimeHours = [1.5, 2.0, 1.0, 2.5, 1.8, 3.0, 2.2];
  static const _kDayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('학습 통계 상세')),
      body: ListView(
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

          // ── Retention curve ──
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
                    values: _kRetentionData,
                    labels: _kDayLabels,
                    color: AppColors.primaryAmber,
                    maxY: 1.0,
                    formatY: (v) => '${(v * 100).toInt()}%',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Accuracy by day ──
          Text('요일별 정확도', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 180,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _BarChartPainter(
                    values: _kAccuracyByDay,
                    labels: _kDayLabels,
                    color: AppColors.success,
                    maxY: 1.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Study time ──
          Text('일별 학습 시간', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 180,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LineChartPainter(
                    values: _kStudyTimeHours,
                    labels: _kDayLabels,
                    color: AppColors.info,
                    maxY: 4.0,
                    formatY: (v) => '${v.toStringAsFixed(1)}h',
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
    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (chartW / (values.length - 1)) * i;
      final y = chartH * (1 - values[i] / maxY);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);

      // X label
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10, color: AppColors.stone400),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 6));
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

      // X label
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

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
