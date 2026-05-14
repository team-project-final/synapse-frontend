import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class NoteListScreen extends ConsumerWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '노트 목록',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-001',
      routeHint: '/notes',
    );
  }
}

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '노트 상세 보기',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-003',
      routeHint: '/notes/$noteId',
    );
  }
}

class NoteEditorScreen extends ConsumerWidget {
  const NoteEditorScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '노트 에디터',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-002',
      routeHint: '/notes/$noteId/edit',
    );
  }
}

class NoteVersionsScreen extends ConsumerWidget {
  const NoteVersionsScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '버전 이력',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-004',
      routeHint: '/notes/$noteId/versions',
    );
  }
}

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '태그 관리',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-005',
      routeHint: '/tags',
    );
  }
}
