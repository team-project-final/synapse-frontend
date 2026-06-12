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
  bool _sharing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filters = ['전체', '최근', '인기'];
    final query = SharedContentQuery(
      query: _searchController.text,
      contentType: SharedContentType.note,
    );
    // 노트 목록도 engagement 공유 메타데이터만 사용한다.
    // 본문 상세는 knowledge 연동 전까지 description/tags/downloadCount 중심으로 표시한다.
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
            const SizedBox(width: AppSpacing.sm),
            FilledButton.icon(
              onPressed: _sharing ? null : () => _showShareNoteDialog(query),
              icon: _sharing
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.ios_share, size: 18),
              label: Text(_sharing ? '등록 중' : '공유 등록'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        notesAsync.when(
          data: (notes) {
            // 필터 버튼과 드롭다운은 모두 실제 메타데이터 정렬로만 연결한다.
            // 임의 별점/카테고리 같은 목업 기준은 사용하지 않는다.
            final order = _selectedFilter == '전체'
                ? _sortOrder
                : _selectedFilter;
            final sortedNotes = _sortSharedContentList(notes, order);
            return Column(
              children: sortedNotes.isEmpty
                  ? <Widget>[const _EmptyGroupList(message: '공유 노트가 없습니다')]
                  : sortedNotes
                      .map<Widget>((note) => _SharedNoteItem(note: note))
                      .toList(),
            );
          },
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

  Future<void> _showShareNoteDialog(SharedContentQuery query) async {
    final draft = await _SharedNoteCreateDialog.show(context);
    if (draft == null || !mounted) {
      return;
    }
    if (draft.noteId.isEmpty || draft.title.isEmpty) {
      AppToast.show(
        context,
        message: '노트 ID와 제목을 입력해주세요',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _sharing = true);
    try {
      // workflow Step 13의 NOTE 공유 생성은 engagement 메타데이터 등록까지 담당한다.
      // 실제 노트 본문 검증/복사는 knowledge 연동 범위라 여기서는 contentId를 그대로 저장한다.
      await ref.read(communityApiProvider).shareContent(
            contentType: SharedContentType.note,
            contentId: draft.noteId,
            title: draft.title,
            description: draft.description,
            tags: draft.tags,
          );
      ref.invalidate(sharedContentsProvider(query));
      if (mounted) {
        AppToast.show(
          context,
          message: '노트를 커뮤니티에 공유했습니다',
          type: ToastType.success,
        );
      }
    } on DioException catch (error) {
      if (mounted) {
        AppToast.show(
          context,
          message: error.response?.statusCode == 403
              ? '노트 공유 권한이 없습니다'
              : '노트 공유 등록에 실패했습니다',
          type: ToastType.error,
        );
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: '노트 공유 등록에 실패했습니다',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
    }
  }
}

class _SharedNoteCreateDialog extends StatelessWidget {
  const _SharedNoteCreateDialog({
    required this.noteIdController,
    required this.titleController,
    required this.descriptionController,
    required this.tagsController,
  });

  final TextEditingController noteIdController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;

  static Future<_SharedNoteDraft?> show(BuildContext context) async {
    final noteIdController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagsController = TextEditingController();
    final result = await showDialog<_SharedNoteDraft>(
      context: context,
      builder: (context) => _SharedNoteCreateDialog(
        noteIdController: noteIdController,
        titleController: titleController,
        descriptionController: descriptionController,
        tagsController: tagsController,
      ),
    );
    noteIdController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('공유 노트 등록'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteIdController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '노트 ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '설명',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: '태그',
                hintText: '쉼표로 구분',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _SharedNoteDraft(
              noteId: noteIdController.text.trim(),
              title: titleController.text.trim(),
              description: descriptionController.text.trim(),
              tags: tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .take(10)
                  .toList(growable: false),
            ),
          ),
          child: const Text('등록'),
        ),
      ],
    );
  }
}

class _SharedNoteDraft {
  const _SharedNoteDraft({
    required this.noteId,
    required this.title,
    required this.description,
    required this.tags,
  });

  final String noteId;
  final String title;
  final String description;
  final List<String> tags;
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
                  const Icon(
                    Icons.download_outlined,
                    size: 12,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${note.downloadCount}회',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
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
