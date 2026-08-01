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

  static const List<String> _clusterNames = ['머신러닝 기초', '학습 최적화', '신경망 구조'];

  @override
  Widget build(BuildContext context) {
    final graphValue = ref.watch(knowledgeGraphProvider);
    return AppAsyncValueWidget<KnowledgeGraphData>(
      value: graphValue,
      isEmpty: (graph) => graph.isEmpty,
      loading: const AppLoadingWidget(label: '클러스터를 불러오는 중입니다.'),
      empty: const AppEmptyState(
        icon: Icons.account_tree_outlined,
        title: '표시할 클러스터가 없습니다.',
      ),
      error: (error, _) => AppErrorWidget(
        message: '클러스터를 불러오지 못했습니다.',
        onRetry: () => ref.invalidate(knowledgeGraphProvider),
      ),
      data: (graph) => _buildClusters(context, graph),
    );
  }

  Widget _buildClusters(BuildContext context, KnowledgeGraphData graph) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    final clusterGroups = _clusterGroups(graph);
    final dimmedClusters = _dimmedClusters(clusterGroups);

    final graphWidget = InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(100),
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _GraphPainter(
            nodes: graph.nodes,
            edges: graph.edges,
            clusterColors: _clusterColors,
            dimmedClusters: dimmedClusters,
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
        for (final entry in clusterGroups.entries)
          _ClusterCard(
            clusterId: entry.key,
            nodes: entry.value,
            isSelected: _selectedCluster == entry.key,
            name: _clusterName(entry.key),
            onTap: () {
              setState(() {
                _selectedCluster = _selectedCluster == entry.key
                    ? null
                    : entry.key;
              });
            },
          ),
        if (_selectedCluster != null) ...[
          const ConceptSectionLabel('선택된 노드', topGap: AppSpacing.md),
          for (final node
              in clusterGroups[_selectedCluster] ??
                  const <KnowledgeGraphNode>[])
            ListTile(
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
            ),
        ],
        const SizedBox(height: AppSpacing.md),
        const ConceptAiComment(
          text: 'PageRank가 높은 노트를 허브로 보고, 연결이 적은 클러스터에는 위키링크를 더 추가해보세요.',
        ),
      ],
    );

    if (isMobile) {
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
              children: [
                for (final entry in clusterGroups.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      avatar: CircleAvatar(
                        backgroundColor:
                            _clusterColors[entry.key % _clusterColors.length],
                        radius: 8,
                      ),
                      label: Text(
                        '${_clusterName(entry.key)} (${entry.value.length})',
                      ),
                      selected: _selectedCluster == entry.key,
                      onSelected: (_) {
                        setState(() {
                          _selectedCluster = _selectedCluster == entry.key
                              ? null
                              : entry.key;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: graphWidget),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 280, child: clusterList),
        const VerticalDivider(width: 1),
        Expanded(child: graphWidget),
      ],
    );
  }

  Map<int, List<KnowledgeGraphNode>> _clusterGroups(KnowledgeGraphData graph) {
    final groups = <int, List<KnowledgeGraphNode>>{};
    for (final node in graph.nodes) {
      groups.putIfAbsent(node.cluster, () => []).add(node);
    }
    return groups;
  }

  Set<int> _dimmedClusters(Map<int, List<KnowledgeGraphNode>> groups) {
    if (_selectedCluster == null) return {};
    return groups.keys.where((cluster) => cluster != _selectedCluster).toSet();
  }

  String _clusterName(int clusterId) {
    if (clusterId < _clusterNames.length) return _clusterNames[clusterId];
    return '클러스터 $clusterId';
  }
}

class _ClusterCard extends StatelessWidget {
  const _ClusterCard({
    required this.clusterId,
    required this.nodes,
    required this.isSelected,
    required this.name,
    required this.onTap,
  });

  final int clusterId;
  final List<KnowledgeGraphNode> nodes;
  final bool isSelected;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _clusterColors[clusterId % _clusterColors.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ConceptCard(
        highlightBorder: isSelected,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        onTap: onTap,
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
  }
}
