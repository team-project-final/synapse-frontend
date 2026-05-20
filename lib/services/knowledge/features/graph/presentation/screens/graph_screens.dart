import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── Shared graph placeholder widget ──

class _GraphPlaceholder extends StatelessWidget {
  const _GraphPlaceholder({this.height = 400});
  final double height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.stone100,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: AppColors.stone300,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hub_outlined, size: 80, color: AppColors.stone300),
            const SizedBox(height: AppSpacing.sm),
            Text('그래프 뷰', style: textTheme.titleMedium
                ?.copyWith(color: AppColors.stone500)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '노트를 작성하면 지식 그래프가 생성됩니다',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
              textAlign: TextAlign.center,
            ),
            // TODO: 팀원 구현 — D3.js/canvas 그래프 렌더링
          ],
        ),
      ),
    );
  }
}

// ── GraphViewScreen (SCR-W-GRAPH-001) ──

class GraphViewScreen extends ConsumerWidget {
  const GraphViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['전체 태그', '날짜', '연결 수'].map((label) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: FilterChip(
                  label: Text(label),
                  selected: label == '전체 태그',
                  selectedColor: colorScheme.primaryContainer,
                  onSelected: (_) {
                    // TODO: 팀원 구현 — 그래프 필터 로직
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Graph placeholder
        const _GraphPlaceholder(height: 400),
        const SizedBox(height: AppSpacing.md),
        // Selected node info panel
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('선택된 노트 정보',
                    style: textTheme.titleSmall
                        ?.copyWith(color: AppColors.stone500)),
                const SizedBox(height: AppSpacing.sm),
                Text('정규화 기법', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '연결 6개 · PageRank 0.85',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.stone500),
                ),
                // TODO: 팀원 구현 — 선택된 노드 데이터 연동
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          context.go(AppRoutes.noteDetailPath('1')),
                      child: const Text('노트 열기'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () => context.go(AppRoutes.aiCards),
                      child: const Text('AI 카드 생성'),
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

// ── GraphNoteScreen (SCR-W-GRAPH-002) ──

class GraphNoteScreen extends ConsumerWidget {
  const GraphNoteScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — knowledge-svc 노트 그래프 API 연동 (noteId: $noteId)
    final mockConnected = [
      {'id': '2', 'title': '드롭아웃 기법', 'relation': '참조'},
      {'id': '3', 'title': '배치 정규화', 'relation': '참조'},
      {'id': '4', 'title': '과적합 방지 기법', 'relation': '역참조'},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Header
        Text('정규화 기법',
            style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text('이웃 그래프',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.stone500)),
        const SizedBox(height: AppSpacing.md),
        // Graph placeholder (smaller)
        const _GraphPlaceholder(height: 300),
        const SizedBox(height: AppSpacing.md),
        // Connected notes
        Text(
          '연결된 노트 (${mockConnected.length})',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...mockConnected.map((note) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: ListTile(
                leading: const Icon(Icons.article_outlined,
                    color: AppColors.stone400),
                title: Text(note['title']!, style: textTheme.bodyMedium),
                subtitle: Text(note['relation']!,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone400)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.stone300),
                onTap: () =>
                    context.go(AppRoutes.noteDetailPath(note['id']!)),
              ),
            )),
      ],
    );
  }
}

// ── GraphClustersScreen (SCR-W-GRAPH-003) ──

class GraphClustersScreen extends ConsumerWidget {
  const GraphClustersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — knowledge-svc 클러스터 API 연동
    const clusters = [
      {'name': '머신러닝', 'color': 0xFF2563EB, 'count': 12},
      {'name': '알고리즘', 'color': 0xFF16A34A, 'count': 8},
      {'name': '네트워크', 'color': 0xFFD97706, 'count': 5},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('클러스터 뷰', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        // Cluster chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: clusters.map((cluster) {
              final color = Color(cluster['color'] as int);
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: color,
                    radius: 8,
                  ),
                  label: Text(cluster['name'] as String),
                  onPressed: () {
                    // TODO: 팀원 구현 — 클러스터 선택 필터
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Graph placeholder
        const _GraphPlaceholder(height: 400),
        const SizedBox(height: AppSpacing.md),
        // Cluster info panel
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2563EB),
                      radius: 8,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('머신러닝 클러스터',
                        style: textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '노트 12개',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.stone500),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '주요 노드: 정규화 기법, 드롭아웃, 과적합',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.stone400),
                ),
                // TODO: 팀원 구현 — 클러스터 상세 데이터 연동
              ],
            ),
          ),
        ),
      ],
    );
  }
}
