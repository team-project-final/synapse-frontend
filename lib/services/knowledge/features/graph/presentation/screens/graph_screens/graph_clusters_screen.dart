part of '../graph_screens.dart';

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
