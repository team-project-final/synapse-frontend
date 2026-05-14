import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class GraphViewScreen extends ConsumerWidget {
  const GraphViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '그래프 뷰',
      domain: 'GRAPH',
      screenId: 'SCR-W-GRAPH-001',
      routeHint: '/graph',
    );
  }
}

class GraphNoteScreen extends ConsumerWidget {
  const GraphNoteScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '노트 이웃',
      domain: 'GRAPH',
      screenId: 'SCR-W-GRAPH-002',
      routeHint: '/graph/notes/$noteId',
    );
  }
}

class GraphClustersScreen extends ConsumerWidget {
  const GraphClustersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '클러스터 뷰',
      domain: 'GRAPH',
      screenId: 'SCR-W-GRAPH-003',
      routeHint: '/graph/clusters',
    );
  }
}
