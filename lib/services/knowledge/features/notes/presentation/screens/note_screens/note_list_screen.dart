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
    final tagsValue = ref.watch(popularTagsProvider);
    final filters = tagsValue.maybeWhen(
      data: (tags) => ['전체', for (final tag in tags.take(8)) tag.tag],
      orElse: () => const ['전체'],
    );
    final query = NoteListQuery(
      tag: _selectedFilter == '전체' ? null : _selectedFilter,
      sortOrder: _sortOrder,
    );
    final notesValue = ref.watch(noteListProvider(query));

    return Stack(
      children: [
        ConceptPage(
          children: [
            ConceptViewHead(
              title: '라이브러리',
              meta: notesValue.maybeWhen(
                data: (page) => '노트 ${page.totalElements}',
                orElse: () => '노트',
              ),
            ),
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
            AppAsyncValueWidget<KnowledgeNotePage>(
              value: notesValue,
              isEmpty: (page) => page.isEmpty,
              loading: const AppLoadingWidget(label: '노트를 불러오는 중입니다.'),
              empty: AppEmptyState(
                icon: Icons.article_outlined,
                title: _selectedFilter == '전체'
                    ? '아직 작성한 노트가 없습니다.'
                    : '#$_selectedFilter 노트가 없습니다.',
                body: '새 노트를 작성하면 라이브러리에 표시됩니다.',
                action: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.noteEditorPath('new')),
                  icon: const Icon(Icons.add),
                  label: const Text('새 노트'),
                ),
              ),
              error: (error, _) => AppErrorWidget(
                message: '노트 목록을 불러오지 못했습니다.',
                onRetry: () => ref.invalidate(noteListProvider(query)),
              ),
              data: (page) => ConceptResponsiveGrid(
                isWide: isWide,
                children: [
                  for (final note in page.items) _NoteCard(note: note),
                ],
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
  final KnowledgeNote note;

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
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              note.snippet,
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
                    children: [
                      for (final tag in note.tags) ConceptTag('#$tag'),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  note.updatedLabel,
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
