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

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final graphValue = ref.watch(
      neighborGraphProvider(
        NeighborGraphQuery(noteId: widget.noteId, depth: _depth.toInt()),
      ),
    );

    return AppAsyncValueWidget<KnowledgeGraphData>(
      value: graphValue,
      isEmpty: (graph) => graph.isEmpty,
      loading: const AppLoadingWidget(label: '이웃 그래프를 불러오는 중입니다.'),
      empty: AppEmptyState(
        icon: Icons.hub_outlined,
        title: '노트를 찾을 수 없습니다.',
        body: 'ID: ${widget.noteId}',
      ),
      error: (error, _) => AppErrorWidget(
        message: '이웃 그래프를 불러오지 못했습니다.',
        onRetry: () => ref.invalidate(
          neighborGraphProvider(
            NeighborGraphQuery(noteId: widget.noteId, depth: _depth.toInt()),
          ),
        ),
      ),
      data: (graph) => _buildGraph(context, graph),
    );
  }

  Widget _buildGraph(BuildContext context, KnowledgeGraphData graph) {
    final textTheme = Theme.of(context).textTheme;
    final centerNode =
        graph.nodes.where((n) => n.id == widget.noteId).firstOrNull ??
        graph.nodes.first;

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
                          '이웃 그래프 · ${math.max(0, graph.nodes.length - 1)}개 연결 노드',
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
                  nodes: graph.nodes,
                  edges: graph.edges,
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
