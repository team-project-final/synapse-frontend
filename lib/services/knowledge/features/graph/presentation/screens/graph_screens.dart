import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';

// ── Mock data models ──

class _MockGraphNode {
  const _MockGraphNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    this.cluster = 0,
    this.linkCount = 0,
    this.pageRank = 0.0,
  });
  final String id;
  final String label;
  final double x;
  final double y;
  final int cluster;
  final int linkCount;
  final double pageRank;
}

class _MockGraphEdge {
  const _MockGraphEdge({required this.from, required this.to});
  final String from;
  final String to;
}

// ── Mock data ──

const List<_MockGraphNode> _mockNodes = [
  _MockGraphNode(
    id: '1',
    label: '정규화 기법',
    x: 350,
    y: 200,
    cluster: 0,
    linkCount: 6,
    pageRank: 0.85,
  ),
  _MockGraphNode(
    id: '2',
    label: '드롭아웃',
    x: 200,
    y: 120,
    cluster: 0,
    linkCount: 4,
    pageRank: 0.62,
  ),
  _MockGraphNode(
    id: '3',
    label: '배치 정규화',
    x: 480,
    y: 140,
    cluster: 0,
    linkCount: 3,
    pageRank: 0.55,
  ),
  _MockGraphNode(
    id: '4',
    label: '과적합 방지',
    x: 150,
    y: 300,
    cluster: 1,
    linkCount: 5,
    pageRank: 0.78,
  ),
  _MockGraphNode(
    id: '5',
    label: '교차 검증',
    x: 280,
    y: 380,
    cluster: 1,
    linkCount: 3,
    pageRank: 0.50,
  ),
  _MockGraphNode(
    id: '6',
    label: '학습률 스케줄링',
    x: 550,
    y: 280,
    cluster: 1,
    linkCount: 2,
    pageRank: 0.40,
  ),
  _MockGraphNode(
    id: '7',
    label: '합성곱 신경망',
    x: 500,
    y: 420,
    cluster: 2,
    linkCount: 4,
    pageRank: 0.72,
  ),
  _MockGraphNode(
    id: '8',
    label: '순환 신경망',
    x: 650,
    y: 350,
    cluster: 2,
    linkCount: 3,
    pageRank: 0.58,
  ),
];

const List<_MockGraphEdge> _mockEdges = [
  _MockGraphEdge(from: '1', to: '2'),
  _MockGraphEdge(from: '1', to: '3'),
  _MockGraphEdge(from: '1', to: '4'),
  _MockGraphEdge(from: '2', to: '4'),
  _MockGraphEdge(from: '4', to: '5'),
  _MockGraphEdge(from: '3', to: '6'),
  _MockGraphEdge(from: '6', to: '7'),
  _MockGraphEdge(from: '7', to: '8'),
  _MockGraphEdge(from: '1', to: '7'),
];

// 컨셉 팔레트(보라/핑크/파랑/초록) — 목업 그래프 노드 색과 매칭.
const List<Color> _clusterColors = [
  AppColors.primary,
  AppColors.accent,
  AppColors.info,
  AppColors.success,
];

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
  });

  final List<_MockGraphNode> nodes;
  final List<_MockGraphEdge> edges;
  final List<Color> clusterColors;
  final String? selectedNodeId;
  final Set<int> dimmedClusters;
  final String? highlightNodeId;
  final double highlightRadius;

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
        oldDelegate.highlightNodeId != highlightNodeId;
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

// ══════════════════════════════════════════════════════════════════════
// 1. GraphViewScreen (SCR-W-GRAPH-001)
// ══════════════════════════════════════════════════════════════════════

class GraphViewScreen extends ConsumerStatefulWidget {
  const GraphViewScreen({super.key});

  @override
  ConsumerState<GraphViewScreen> createState() => _GraphViewScreenState();
}

class _GraphViewScreenState extends ConsumerState<GraphViewScreen> {
  final TransformationController _transformController =
      TransformationController();
  String? _selectedNodeId;
  final Set<String> _selectedTags = {'전체'};
  double _minLinks = 0;

  static const List<String> _filterTags = ['전체', '머신러닝', '딥러닝', '통계'];

  List<_MockGraphNode> get _filteredNodes {
    return _mockNodes.where((n) => n.linkCount >= _minLinks).toList();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final matrix = _transformController.value.clone()..invert();
    final localPosition = MatrixUtils.transformPoint(
      matrix,
      details.localPosition,
    );

    final hit = _hitTestNode(_filteredNodes, localPosition);
    setState(() {
      _selectedNodeId = hit?.id;
    });
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedNode = _selectedNodeId != null
        ? _filteredNodes.where((n) => n.id == _selectedNodeId).firstOrNull
        : null;

    return Stack(
      children: [
        Column(
          children: [
            // Filter panel
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  '필터',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                leading: const Icon(
                  Icons.filter_list,
                  size: 20,
                  color: AppColors.primary,
                ),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _filterTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return ConceptFilterPill(
                        label: tag,
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        '최소 연결 수: ${_minLinks.toInt()}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _minLinks,
                          min: 0,
                          max: 6,
                          divisions: 6,
                          label: _minLinks.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              _minLinks = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 태그 색상 범례 (v1 ⑧ legend) — 노드 크기=PageRank, 색=태그.
            const _GraphLegend(),
            // Graph area
            Expanded(
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.5,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(100),
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: _GraphPainter(
                        nodes: _filteredNodes,
                        edges: _mockEdges,
                        clusterColors: _clusterColors,
                        selectedNodeId: _selectedNodeId,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // 노드 미선택 시 AI 허브 분석 코멘트(v1 ⑧ ai-comment).
        if (selectedNode == null)
          const Positioned(
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: ConceptAiComment(
              text:
                  '「정규화 기법」이 가장 중요한 허브예요(PageRank 1위). '
                  '「신경망 구조」 클러스터는 다른 노트와 연결이 적으니 위키링크를 더 만들어 보세요.',
            ),
          ),
        // Fit FAB — 노드 선택 패널/AI 코멘트 위로 띄운다.
        Positioned(
          right: AppSpacing.md,
          bottom: selectedNode != null ? 220 : 96,
          child: FloatingActionButton.small(
            heroTag: 'fit_screen',
            onPressed: _resetView,
            child: const Icon(Icons.fit_screen),
          ),
        ),
        // Selected node info panel
        if (selectedNode != null)
          Positioned(
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: ConceptCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            _clusterColors[selectedNode.cluster %
                                _clusterColors.length],
                        radius: 8,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          selectedNode.label,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: AppColors.muted,
                        onPressed: () => setState(() => _selectedNodeId = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '연결 ${selectedNode.linkCount}개 · PageRank ${selectedNode.pageRank.toStringAsFixed(2)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.go(
                          AppRoutes.noteDetailPath(selectedNode.id),
                        ),
                        icon: const Icon(Icons.article_outlined, size: 16),
                        label: const Text('노트 열기'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.aiCards),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('AI 카드 생성'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go(
                          AppRoutes.graphNotePath(selectedNode.id),
                        ),
                        icon: const Icon(Icons.hub_outlined, size: 16),
                        label: const Text('이웃 확장'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 그래프 태그 색상 범례 (v1 ⑧ `.legend`). 색 = 태그(클러스터).
class _GraphLegend extends StatelessWidget {
  const _GraphLegend();

  // _clusterColors 순서와 매칭되는 태그 라벨.
  static const _labels = ['머신러닝', '딥러닝', '아키텍처', '알고리즘'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm + 2,
        runSpacing: AppSpacing.xs,
        children: [
          for (int i = 0; i < _labels.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: _clusterColors[i % _clusterColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _labels[i],
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// 2. GraphNoteScreen (SCR-W-GRAPH-002)
// ══════════════════════════════════════════════════════════════════════

class GraphNoteScreen extends ConsumerStatefulWidget {
  const GraphNoteScreen({required this.noteId, super.key});
  final String noteId;

  @override
  ConsumerState<GraphNoteScreen> createState() => _GraphNoteScreenState();
}

class _GraphNoteScreenState extends ConsumerState<GraphNoteScreen> {
  final TransformationController _transformController =
      TransformationController();
  double _depth = 1;

  _MockGraphNode? get _centerNode {
    return _mockNodes.where((n) => n.id == widget.noteId).firstOrNull;
  }

  /// Collect neighbors up to [maxHops] hops from the center node.
  List<_MockGraphNode> _getNeighborNodes(int maxHops) {
    final Set<String> visited = {widget.noteId};
    Set<String> frontier = {widget.noteId};

    for (int hop = 0; hop < maxHops; hop++) {
      final Set<String> nextFrontier = {};
      for (final nodeId in frontier) {
        for (final edge in _mockEdges) {
          if (edge.from == nodeId && !visited.contains(edge.to)) {
            nextFrontier.add(edge.to);
            visited.add(edge.to);
          }
          if (edge.to == nodeId && !visited.contains(edge.from)) {
            nextFrontier.add(edge.from);
            visited.add(edge.from);
          }
        }
      }
      frontier = nextFrontier;
    }

    return _mockNodes.where((n) => visited.contains(n.id)).toList();
  }

  List<_MockGraphEdge> _getRelevantEdges(List<_MockGraphNode> nodes) {
    final nodeIds = nodes.map((n) => n.id).toSet();
    return _mockEdges
        .where((e) => nodeIds.contains(e.from) && nodeIds.contains(e.to))
        .toList();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final centerNode = _centerNode;

    if (centerNode == null) {
      return Center(
        child: Text(
          '노트를 찾을 수 없습니다 (ID: ${widget.noteId})',
          style: textTheme.bodyLarge,
        ),
      );
    }

    final neighborNodes = _getNeighborNodes(_depth.toInt());
    final relevantEdges = _getRelevantEdges(neighborNodes);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.muted,
                    onPressed: () => context.go(AppRoutes.graph),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          centerNode.label,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '이웃 그래프 · ${neighborNodes.length - 1}개 연결 노드',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Depth slider
              Row(
                children: [
                  Text(
                    '탐색 깊이: ${_depth.toInt()}홉',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _depth,
                      min: 1,
                      max: 2,
                      divisions: 1,
                      label: '${_depth.toInt()}홉',
                      onChanged: (value) {
                        setState(() {
                          _depth = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Graph area
        Expanded(
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.5,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(100),
            child: SizedBox.expand(
              child: CustomPaint(
                painter: _GraphPainter(
                  nodes: neighborNodes,
                  edges: relevantEdges,
                  clusterColors: _clusterColors,
                  highlightNodeId: widget.noteId,
                  highlightRadius: 30.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// 3. GraphClustersScreen (SCR-W-GRAPH-003)
// ══════════════════════════════════════════════════════════════════════

class GraphClustersScreen extends ConsumerStatefulWidget {
  const GraphClustersScreen({super.key});

  @override
  ConsumerState<GraphClustersScreen> createState() =>
      _GraphClustersScreenState();
}

class _GraphClustersScreenState extends ConsumerState<GraphClustersScreen> {
  int? _selectedCluster;

  /// Group nodes by cluster for the side panel.
  Map<int, List<_MockGraphNode>> get _clusterGroups {
    final Map<int, List<_MockGraphNode>> groups = {};
    for (final node in _mockNodes) {
      groups.putIfAbsent(node.cluster, () => []).add(node);
    }
    return groups;
  }

  static const List<String> _clusterNames = ['머신러닝 기초', '학습 최적화', '신경망 구조'];

  Set<int> get _dimmedClusters {
    if (_selectedCluster == null) return {};
    final all = _clusterGroups.keys.toSet();
    all.remove(_selectedCluster);
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    final graphWidget = InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(100),
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _GraphPainter(
            nodes: _mockNodes,
            edges: _mockEdges,
            clusterColors: _clusterColors,
            dimmedClusters: _dimmedClusters,
          ),
        ),
      ),
    );

    final clusterList = ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          '클러스터',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._clusterGroups.entries.map((entry) {
          final clusterId = entry.key;
          final nodes = entry.value;
          final isSelected = _selectedCluster == clusterId;
          final color = _clusterColors[clusterId % _clusterColors.length];
          final name = clusterId < _clusterNames.length
              ? _clusterNames[clusterId]
              : '클러스터 $clusterId';

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ConceptCard(
              highlightBorder: isSelected,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              onTap: () {
                setState(() {
                  _selectedCluster = isSelected ? null : clusterId;
                });
              },
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: color, radius: 10),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${nodes.length}개 노드',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          );
        }),
        if (_selectedCluster != null) ...[
          const ConceptSectionLabel('선택된 노드', topGap: AppSpacing.md),
          ...(_clusterGroups[_selectedCluster] ?? []).map((node) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.circle,
                size: 8,
                color: _clusterColors[node.cluster % _clusterColors.length],
              ),
              title: Text(node.label, style: textTheme.bodySmall),
              subtitle: Text(
                '연결 ${node.linkCount}개',
                style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
              onTap: () => context.go(AppRoutes.graphNotePath(node.id)),
            );
          }),
        ],
        // AI 허브 분석 (목업 ai-comment)
        const SizedBox(height: AppSpacing.md),
        const ConceptAiComment(
          text:
              '「정규화 기법」이 가장 중요한 허브예요(PageRank 1위). 「신경망 구조」 클러스터는 다른 노트와 연결이 적으니 위키링크를 더 만들어 보세요.',
        ),
      ],
    );

    if (isMobile) {
      // Mobile: cluster chips on top, graph below
      return Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              children: _clusterGroups.entries.map((entry) {
                final clusterId = entry.key;
                final nodes = entry.value;
                final isSelected = _selectedCluster == clusterId;
                final color = _clusterColors[clusterId % _clusterColors.length];
                final name = clusterId < _clusterNames.length
                    ? _clusterNames[clusterId]
                    : '클러스터 $clusterId';

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    avatar: CircleAvatar(backgroundColor: color, radius: 8),
                    label: Text('$name (${nodes.length})'),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCluster = isSelected ? null : clusterId;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: graphWidget),
        ],
      );
    }

    // Desktop: side panel + graph
    return Row(
      children: [
        SizedBox(width: 280, child: clusterList),
        const VerticalDivider(width: 1),
        Expanded(child: graphWidget),
      ],
    );
  }
}
