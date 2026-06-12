part of '../note_screens.dart';

// ── NoteListScreen (SCR-W-NOTE-001) ──

class NoteListScreen extends ConsumerStatefulWidget {
  const NoteListScreen({super.key});

  @override
  ConsumerState<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends ConsumerState<NoteListScreen> {
  String _selectedFilter = '전체';
  String _sortOrder = '최근 수정';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final filters = ['전체', '머신러닝', '딥러닝', '알고리즘', 'AWS'];

    return Stack(
      children: [
        ConceptPage(
          children: [
            const ConceptViewHead(title: '라이브러리', meta: '노트 24'),
            // Search bar (탭하면 검색 화면) — 데모용
            // TODO: 팀원 구현 — knowledge-svc 검색 API 연동
            ConceptSearchBar(
              hint: '노트 검색…',
              onTap: () => context.go(AppRoutes.search),
            ),
            const SizedBox(height: AppSpacing.md),
            // Filter pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in filters) ...[
                    ConceptFilterPill(
                      label: f,
                      selected: _selectedFilter == f,
                      onTap: () => setState(() => _selectedFilter = f),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Sort order
            Row(
              children: [
                Text(
                  '정렬',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                DropdownButton<String>(
                  value: _sortOrder,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                  items: const [
                    DropdownMenuItem(value: '최근 수정', child: Text('최근 수정')),
                    DropdownMenuItem(value: '제목순', child: Text('제목순')),
                    DropdownMenuItem(value: '생성일', child: Text('생성일')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _sortOrder = v);
                  },
                ),
              ],
            ),
            const ConceptSectionLabel('최근 노트', topGap: AppSpacing.md),
            // Note list — knowledge-svc 노트 목록 API(GET /api/v1/notes) 연동
            ref.watch(notesListProvider).when(
              data: (List<Note> notes) => notes.isEmpty
                  ? const _NotesEmpty()
                  : ConceptResponsiveGrid(
                      isWide: isWide,
                      children: <Widget>[
                        for (final Note note in notes) _NoteCard(note: note),
                      ],
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object error, StackTrace stackTrace) => _NotesError(
                onRetry: () => ref.invalidate(notesListProvider),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
          ],
        ),
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: FloatingActionButton.extended(
            onPressed: () => context.go(AppRoutes.noteEditorPath('new')),
            icon: const Icon(Icons.add),
            label: const Text('새 노트'),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final Note note;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: ConceptCard(
        onTap: () => context.go(AppRoutes.noteDetailPath(note.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              note.contentPlain,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.xs + 2,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final String tag in note.tags) ConceptTag('#$tag'),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatTimeAgo(note.updatedAt),
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// updatedAt 을 "방금 전 / N분 전 / N시간 전 / N일 전 / yyyy.MM.dd" 로 표시한다.
String _formatTimeAgo(DateTime time) {
  final Duration diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) {
    return '방금 전';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes}분 전';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}시간 전';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}일 전';
  }
  final String two = time.month.toString().padLeft(2, '0');
  final String day = time.day.toString().padLeft(2, '0');
  return '${time.year}.$two.$day';
}

/// 노트가 하나도 없을 때.
class _NotesEmpty extends StatelessWidget {
  const _NotesEmpty();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Text(
          '아직 노트가 없어요. 새 노트를 작성해 보세요.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
      ),
    );
  }
}

/// 목록 로딩 실패 시 재시도 UI.
class _NotesError extends StatelessWidget {
  const _NotesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              '노트를 불러오지 못했어요.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
