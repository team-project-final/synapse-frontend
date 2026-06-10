part of '../community_screens.dart';

// ── SharedNotesScreen (SCR-W-COMM-006) ──

class SharedNotesScreen extends ConsumerStatefulWidget {
  const SharedNotesScreen({super.key});

  @override
  ConsumerState<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends ConsumerState<SharedNotesScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = '전체';
  String _sortOrder = '최신순';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filters = ['전체', '최근', '인기', '내 그룹'];
    final query = SharedContentQuery(
      query: _searchController.text,
      contentType: SharedContentType.note,
    );
    final notesAsync = ref.watch(sharedContentsProvider(query));

    return ConceptPage(
      children: [
        // Search bar
        StudySearchBar(
          hint: '공유 노트 검색…',
          controller: _searchController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        // Filter pills + sort dropdown
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: StudyPill(
                        label: f,
                        selected: _selectedFilter == f,
                        onTap: () => setState(() => _selectedFilter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            DropdownButton<String>(
              value: _sortOrder,
              underline: const SizedBox.shrink(),
              style: textTheme.labelLarge?.copyWith(color: AppColors.text),
              items: const [
                DropdownMenuItem(value: '최신순', child: Text('최신순')),
                DropdownMenuItem(value: '인기순', child: Text('인기순')),
              ],
              onChanged: (v) => setState(() => _sortOrder = v ?? '최신순'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        notesAsync.when(
          data: (notes) => Column(
            children: notes.isEmpty
                ? <Widget>[const _EmptyGroupList(message: '공유 노트가 없습니다')]
                : notes
                    .map<Widget>((note) => _SharedNoteItem(note: note))
                    .toList(),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          error: (_, _) => _ErrorState(
            message: '공유 노트를 불러오지 못했습니다',
            onRetry: () => ref.invalidate(sharedContentsProvider(query)),
          ),
        ),
      ],
    );
  }
}

class _SharedNoteItem extends StatelessWidget {
  const _SharedNoteItem({required this.note});
  final SharedContent note;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          context.go(AppRoutes.communitySharedNoteDetailPath(note.shareToken));
        },
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 16,
                    color: AppColors.primaryAmber,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(note.title, style: textTheme.titleSmall)),
                  Text(
                    _formatRelativeTime(note.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 12,
                    color: AppColors.stone400,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'User ${note.ownerId}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone400,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.star, size: 12, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '4.0',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone500,
                    ),
                  ),
                ],
              ),
              // Preview text
              if (note.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  note.description,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.stone500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              if (note.tags.isNotEmpty)
                Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: note.tags
                    .map((tag) => StudyTag(label: '#$tag'))
                    .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
