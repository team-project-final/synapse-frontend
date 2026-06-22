part of '../note_screens.dart';

// ── NoteVersionsScreen (SCR-W-NOTE-004) ──

class NoteVersionsScreen extends ConsumerStatefulWidget {
  const NoteVersionsScreen({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<NoteVersionsScreen> createState() => _NoteVersionsScreenState();
}

class _NoteVersionsScreenState extends ConsumerState<NoteVersionsScreen> {
  int? _selectedVersionNo;
  AsyncValue<KnowledgeNoteVersion>? _selectedVersionValue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final versionsValue = ref.watch(noteVersionsProvider(widget.noteId));

    return ConceptPage(
      children: [
        const ConceptViewHead(title: '버전 이력'),
        Text(
          '노트 ID: ${widget.noteId}',
          style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        AppAsyncValueWidget<List<KnowledgeNoteVersion>>(
          value: versionsValue,
          isEmpty: (items) => items.isEmpty,
          loading: const AppLoadingWidget(label: '버전 이력을 불러오는 중입니다.'),
          empty: const AppEmptyState(
            icon: Icons.history,
            title: '아직 저장된 버전이 없습니다.',
          ),
          error: (error, _) => AppErrorWidget(
            message: '버전 이력을 불러오지 못했습니다.',
            onRetry: () => ref.invalidate(noteVersionsProvider(widget.noteId)),
          ),
          data: (versions) => Column(
            children: [
              for (final version in versions)
                _VersionItem(
                  version: 'v${version.versionNo}',
                  date: _formatVersionDate(version.createdAt),
                  description: version.title,
                  isSelected: _selectedVersionNo == version.versionNo,
                  onTap: () => _selectVersion(version.versionNo),
                  onRestore: () =>
                      unawaited(_restoreVersion(version.versionNo)),
                ),
            ],
          ),
        ),
        if (_selectedVersionNo != null) ...[
          ConceptSectionLabel('버전 내용 (v$_selectedVersionNo)'),
          AppAsyncValueWidget<KnowledgeNoteVersion>(
            value: _selectedVersionValue ?? const AsyncLoading(),
            loading: const AppLoadingWidget(label: '버전 내용을 불러오는 중입니다.'),
            error: (error, _) =>
                const AppErrorWidget(message: '버전 내용을 불러오지 못했습니다.'),
            data: (version) =>
                ConceptCard(child: MarkdownBody(data: version.contentMd ?? '')),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Future<void> _selectVersion(int versionNo) async {
    setState(() {
      _selectedVersionNo = versionNo;
      _selectedVersionValue = const AsyncLoading();
    });
    final value = await AsyncValue.guard(
      () => ref
          .read(knowledgeApiProvider)
          .getVersion(noteId: widget.noteId, versionNo: versionNo),
    );
    if (!mounted) return;
    setState(() => _selectedVersionValue = value);
  }

  Future<void> _restoreVersion(int versionNo) async {
    final restored = await AsyncValue.guard(
      () => ref
          .read(knowledgeApiProvider)
          .restoreVersion(noteId: widget.noteId, versionNo: versionNo),
    );
    restored.whenOrNull(
      data: (note) {
        ref.invalidate(noteDetailProvider(widget.noteId));
        ref.invalidate(noteVersionsProvider(widget.noteId));
        ref.invalidate(noteListProvider);
        if (mounted) context.go(AppRoutes.noteDetailPath(note.id));
      },
    );
  }
}

class _VersionItem extends StatelessWidget {
  const _VersionItem({
    required this.version,
    required this.date,
    required this.description,
    this.isSelected = false,
    this.onTap,
    this.onRestore,
  });
  final String version;
  final String date;
  final String description;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ConceptCard(
        onTap: onTap,
        highlightBorder: isSelected,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                version,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    date,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onRestore,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('복원'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatVersionDate(DateTime? value) {
  if (value == null) return '시간 미상';
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
