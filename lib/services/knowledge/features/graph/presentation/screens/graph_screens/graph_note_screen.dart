part of '../graph_screens.dart';

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
