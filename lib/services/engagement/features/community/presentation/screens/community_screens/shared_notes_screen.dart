part of '../community_screens.dart';

// ── SharedNotesScreen (SCR-W-COMM-006) ──

class SharedNotesScreen extends ConsumerStatefulWidget {
  const SharedNotesScreen({super.key});

  @override
  ConsumerState<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends ConsumerState<SharedNotesScreen> {
  final _searchController = TextEditingController();
  SharedContentSort _sortOrder = SharedContentSort.recent;
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = SharedContentQuery(
      contentType: 'NOTE',
      searchText: _searchText,
      sortOrder: _sortOrder,
    );
    final notesValue = ref.watch(sharedContentSearchProvider(query));

    return ConceptPage(
      children: [
        StudySearchBar(
          hint: '공유 노트 검색…',
          controller: _searchController,
          onChanged: (value) => setState(() => _searchText = value.trim()),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: SharedContentSort.values.map((sort) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: StudyPill(
                  label: sort.label,
                  selected: _sortOrder == sort,
                  onTap: () => setState(() => _sortOrder = sort),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppAsyncValueWidget<List<SharedContent>>(
          value: notesValue,
          loading: const AppLoadingWidget(label: '공유 노트를 불러오는 중입니다.'),
          error: (error, _) => AppErrorWidget(
            message: '공유 노트를 불러오지 못했습니다.',
            onRetry: () => ref.invalidate(sharedContentSearchProvider(query)),
          ),
          isEmpty: (items) => items.isEmpty,
          empty: const AppEmptyState(
            icon: Icons.article_outlined,
            title: '공유된 노트가 없습니다.',
          ),
          data: (notes) => Column(
            children: [for (final note in notes) _SharedNoteItem(note: note)],
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
        onTap: () => context.go(
          AppRoutes.communitySharedNoteDetailPath(note.shareToken),
        ),
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
                  Expanded(
                    child: Text(note.title, style: textTheme.titleSmall),
                  ),
                  Text(
                    note.createdLabel,
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
                    note.ownerLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone400,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.download_outlined,
                    size: 12,
                    color: AppColors.stone400,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    _formatCount(note.downloadCount),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.stone500,
                    ),
                  ),
                ],
              ),
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
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: note.tags
                      .map((tag) => StudyTag(label: '#$tag'))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
