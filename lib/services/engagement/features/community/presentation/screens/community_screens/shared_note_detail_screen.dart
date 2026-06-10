part of '../community_screens.dart';

class SharedNoteDetailScreen extends ConsumerWidget {
  const SharedNoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(sharedContentProvider(noteId));

    return contentAsync.when(
      data: (note) => _SharedContentDetail(
        content: note,
        icon: Icons.article_outlined,
        copiedMessage: '노트가 내 라이브러리에 복사되었습니다',
      ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _ErrorState(
        message: '공유 노트를 불러오지 못했습니다',
        onRetry: () => ref.invalidate(sharedContentProvider(noteId)),
      ),
    );
  }
}
