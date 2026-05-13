import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class CommunityGroupsScreen extends ConsumerWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '스터디 그룹 목록',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-001',
      routeHint: '/community/groups',
    );
  }
}

class CommunityGroupDetailScreen extends ConsumerWidget {
  const CommunityGroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '그룹 상세/멤버',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-002',
      routeHint: '/community/groups/$groupId',
    );
  }
}

class CommunityGroupEditorScreen extends ConsumerWidget {
  const CommunityGroupEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '그룹 생성/편집',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-003',
      routeHint: '/community/groups/new',
    );
  }
}

class SharedDecksScreen extends ConsumerWidget {
  const SharedDecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '공유 덱 탐색',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-004',
      routeHint: '/community/shared-decks',
    );
  }
}

class SharedDeckDetailScreen extends ConsumerWidget {
  const SharedDeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '공유 덱 상세',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-005',
      routeHint: '/community/shared-decks/$deckId',
    );
  }
}

class SharedNotesScreen extends ConsumerWidget {
  const SharedNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '공유 노트 탐색',
      domain: 'COMMUNITY',
      screenId: 'SCR-W-COMM-006',
      routeHint: '/community/shared-notes',
    );
  }
}
