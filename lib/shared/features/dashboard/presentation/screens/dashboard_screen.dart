import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/onboarding_checklist.dart';

// ── Mock data ──────────────────────────────────────────────────────────────

const _kReviewCardCount = 12;
const _kTotalCards = 78;
const _kAccuracyPercent = 82;
const _kStreakDays = 5;

const _kMockNotes = [
  _MockNote(
    title: '운영체제 가상 메모리 정리',
    snippet: '페이지 교체 알고리즘 비교: FIFO, LRU, Optimal...',
    timeAgo: '30분 전',
  ),
  _MockNote(
    title: 'Flutter 상태 관리 패턴',
    snippet: 'Riverpod의 Provider 종류와 사용 시점 정리...',
    timeAgo: '2시간 전',
  ),
  _MockNote(
    title: '이산수학 그래프 이론',
    snippet: 'BFS와 DFS 시간복잡도 및 활용 사례...',
    timeAgo: '어제',
  ),
];

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

// ── Helper model ───────────────────────────────────────────────────────────

class _MockNote {
  const _MockNote({
    required this.title,
    required this.snippet,
    required this.timeAgo,
  });
  final String title;
  final String snippet;
  final String timeAgo;
}

// ═══════════════════════════════════════════════════════════════════════════
// DASH-001  DashboardScreen
// ═══════════════════════════════════════════════════════════════════════════

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── Review card ──
        Text('오늘의 학습', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('복습 대기', style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$_kReviewCardCount장',
                        style: textTheme.headlineLarge
                            ?.copyWith(color: colorScheme.primary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // TODO: 팀원 구현 — learning-svc 복습 대기 카드 수 연동
                      Text(
                        '오늘 복습할 카드가 준비되어 있습니다',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.stone400),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.review),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('복습 시작'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Onboarding checklist ──
        const OnboardingChecklist(),
        const SizedBox(height: AppSpacing.xl),

        // ── Stats cards ──
        Text('학습 현황', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: '복습 카드',
                value: '$_kTotalCards장',
                icon: Icons.style_outlined,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: _StatCard(
                label: '정확도',
                value: '$_kAccuracyPercent%',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: _StatCard(
                label: '연속 학습',
                value: '$_kStreakDays일 🔥',
                icon: Icons.local_fire_department,
                color: AppColors.primaryAmber,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go(AppRoutes.dashboardStats),
            child: const Text('더보기'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Mini heatmap ──
        Text('학습 히트맵', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => context.go(AppRoutes.dashboardHeatmap),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 100,
                child: CustomPaint(
                  painter: _HeatmapMiniPainter(
                    data: _generateHeatmapData(84), // 12 weeks
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go(AppRoutes.dashboardHeatmap),
            child: const Text('더보기'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Recent notes ──
        Text('최근 노트', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: [
              // TODO: 팀원 구현 — knowledge-svc 최근 노트 목록 연동
              for (int i = 0; i < _kMockNotes.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: AppColors.stone400),
                  title: Text(_kMockNotes[i].title,
                      style: textTheme.bodyMedium),
                  subtitle: Text(
                    _kMockNotes[i].snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone500),
                  ),
                  trailing: Text(
                    _kMockNotes[i].timeAgo,
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppColors.stone400),
                  ),
                  onTap: () => context.go(AppRoutes.notes),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go(AppRoutes.notes),
            child: const Text('더보기'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ── Stat card widget ───────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style:
                  textTheme.bodySmall?.copyWith(color: AppColors.stone500),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini heatmap painter ───────────────────────────────────────────────────

class _HeatmapMiniPainter extends CustomPainter {
  _HeatmapMiniPainter({required this.data});

  final List<int> data;

  static const int _cols = 12;
  static const int _rows = 7;

  Color _colorForCount(int count) {
    if (count == 0) return AppColors.stone100;
    if (count <= 2) return const Color(0xFFBBF7D0);
    if (count <= 5) return const Color(0xFF4ADE80);
    if (count <= 9) return const Color(0xFF16A34A);
    return const Color(0xFF166534);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = (size.width - (_cols - 1) * 2) / _cols;
    final cellH = (size.height - (_rows - 1) * 2) / _rows;
    final cellSize = math.min(cellW, cellH);
    const gap = 2.0;

    for (int col = 0; col < _cols; col++) {
      for (int row = 0; row < _rows; row++) {
        final index = col * _rows + row;
        final count = index < data.length ? data[index] : 0;
        final paint = Paint()..color = _colorForCount(count);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            col * (cellSize + gap),
            row * (cellSize + gap),
            cellSize,
            cellSize,
          ),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapMiniPainter oldDelegate) =>
      oldDelegate.data != data;
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
    if (count == 0) return AppColors.stone100;
    if (count <= 2) return const Color(0xFFBBF7D0);
    if (count <= 5) return const Color(0xFF4ADE80);
    if (count <= 9) return const Color(0xFF16A34A);
    return const Color(0xFF166534);
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
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
    if (count == 0) return AppColors.stone100;
    if (count <= 2) return const Color(0xFFBBF7D0);
    if (count <= 5) return const Color(0xFF4ADE80);
    if (count <= 9) return const Color(0xFF16A34A);
    return const Color(0xFF166534);
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

class _DashboardStatsScreenState
    extends ConsumerState<DashboardStatsScreen> {
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
