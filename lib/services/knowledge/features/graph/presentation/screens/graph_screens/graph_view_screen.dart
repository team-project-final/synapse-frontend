part of '../graph_screens.dart';

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
  // 그래프를 영역 중앙에 맞추는 오프셋. LayoutBuilder에서 매 빌드 갱신,
  // 페인터와 탭 히트테스트가 같은 값을 공유한다.
  Offset _graphOffset = Offset.zero;

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

    final hit = _hitTestNode(_filteredNodes, localPosition - _graphOffset);
    setState(() {
      _selectedNodeId = hit?.id;
    });
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }

  /// 노드 묶음의 중심을 그래프 영역 중앙에 맞추는 오프셋(좌측 쏠림 방지).
  Offset _centerOffset(Size size) {
    final ns = _filteredNodes;
    if (ns.isEmpty) return Offset.zero;
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final n in ns) {
      minX = math.min(minX, n.x);
      maxX = math.max(maxX, n.x);
      minY = math.min(minY, n.y);
      maxY = math.max(maxY, n.y);
    }
    return Offset(
      size.width / 2 - (minX + maxX) / 2,
      size.height / 2 - (minY + maxY) / 2,
    );
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _graphOffset = _centerOffset(constraints.biggest);
                  return InteractiveViewer(
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
                            offset: _graphOffset,
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
