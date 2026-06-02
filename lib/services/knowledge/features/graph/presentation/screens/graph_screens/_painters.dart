part of '../graph_screens.dart';

// ── Shared Graph Painter ──

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.nodes,
    required this.edges,
    required this.clusterColors,
    this.selectedNodeId,
    this.dimmedClusters = const {},
    this.highlightNodeId,
    this.highlightRadius = 30.0,
    this.offset = Offset.zero,
  });

  final List<_MockGraphNode> nodes;
  final List<_MockGraphEdge> edges;
  final List<Color> clusterColors;
  final String? selectedNodeId;
  final Set<int> dimmedClusters;
  final String? highlightNodeId;
  final double highlightRadius;

  /// 그래프 전체를 영역 중앙으로 평행이동하는 오프셋(넓은 화면 중앙 정렬).
  final Offset offset;

  static const double _defaultNodeRadius = 20.0;
  // PageRank → 반지름 매핑 범위 (v1: 노드 크기 = PageRank).
  static const double _minRadius = 14.0;
  static const double _maxRadius = 30.0;

  /// PageRank(0~1 가정)를 반지름으로 선형 매핑. 데이터가 없으면 기본값.
  double _radiusFor(_MockGraphNode node) {
    if (node.pageRank <= 0) return _defaultNodeRadius;
    final r =
        _minRadius + (_maxRadius - _minRadius) * node.pageRank.clamp(0.0, 1.0);
    return r;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 노드 좌표는 고정값이라, 전체를 오프셋만큼 옮겨 영역 중앙에 맞춘다.
    canvas.translate(offset.dx, offset.dy);

    final Map<String, _MockGraphNode> nodeMap = {
      for (final n in nodes) n.id: n,
    };

    // Draw edges
    for (final edge in edges) {
      final from = nodeMap[edge.from];
      final to = nodeMap[edge.to];
      if (from == null || to == null) continue;

      final fromDimmed = dimmedClusters.contains(from.cluster);
      final toDimmed = dimmedClusters.contains(to.cluster);
      final edgeDimmed = fromDimmed || toDimmed;

      final paint = Paint()
        ..color = (edgeDimmed
            ? AppColors.border.withValues(alpha: 0.4)
            : AppColors.border)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(from.x, from.y), Offset(to.x, to.y), paint);
    }

    // Draw nodes
    for (final node in nodes) {
      final isDimmed = dimmedClusters.contains(node.cluster);
      final isSelected = node.id == selectedNodeId;
      final isHighlight = node.id == highlightNodeId;
      // 명시적 하이라이트가 있으면 고정 반지름, 아니면 PageRank로 크기 결정.
      final radius = isHighlight ? highlightRadius : _radiusFor(node);

      final clusterColor = clusterColors[node.cluster % clusterColors.length];
      final color = isDimmed
          ? clusterColor.withValues(alpha: 0.2)
          : clusterColor;

      // Selection highlight ring
      if (isSelected) {
        final ringPaint = Paint()
          ..color = clusterColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        canvas.drawCircle(Offset(node.x, node.y), radius + 6, ringPaint);
      }

      // Node fill
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(node.x, node.y), radius, fillPaint);

      // Node border
      final borderPaint = Paint()
        ..color = isDimmed
            ? AppColors.surface.withValues(alpha: 0.3)
            : AppColors.surface.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(node.x, node.y), radius, borderPaint);

      // Label
      final textSpan = TextSpan(
        text: node.label,
        style: TextStyle(
          color: isDimmed
              ? AppColors.muted.withValues(alpha: 0.4)
              : AppColors.text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(node.x - textPainter.width / 2, node.y + radius + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.dimmedClusters != dimmedClusters ||
        oldDelegate.nodes != nodes ||
        oldDelegate.highlightNodeId != highlightNodeId ||
        oldDelegate.offset != offset;
  }
}

// ── Helper: hit-test node ──

_MockGraphNode? _hitTestNode(
  List<_MockGraphNode> nodes,
  Offset position, {
  double threshold = 25.0,
}) {
  for (final node in nodes) {
    final dx = node.x - position.dx;
    final dy = node.y - position.dy;
    if (math.sqrt(dx * dx + dy * dy) < threshold) {
      return node;
    }
  }
  return null;
}
