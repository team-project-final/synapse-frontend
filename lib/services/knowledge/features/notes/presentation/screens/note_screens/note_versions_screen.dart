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
  bool _restoring = false;

  /// 특정 버전으로 복원 → 노트 상세로 이동 + 관련 캐시 무효화.
  Future<void> _restore(int versionNo) async {
    setState(() => _restoring = true);
    try {
      await ref
          .read(restoreNoteVersionUseCaseProvider)
          .call(widget.noteId, versionNo);
      ref.invalidate(notesListProvider);
      ref.invalidate(noteDetailProvider(widget.noteId));
      ref.invalidate(noteVersionsProvider(widget.noteId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('v$versionNo 버전으로 복원했어요')),
      );
      context.go(AppRoutes.noteDetailPath(widget.noteId));
    } catch (_) {
      if (!mounted) return;
      setState(() => _restoring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('복원에 실패했어요. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final AsyncValue<List<NoteVersionSummary>> versions =
        ref.watch(noteVersionsProvider(widget.noteId));

    return ConceptPage(
      children: [
        const ConceptViewHead(title: '버전 이력'),
        // knowledge-svc 버전 이력 API(GET /notes/{id}/versions) 연동
        versions.when(
          data: (List<NoteVersionSummary> list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    '저장된 버전 이력이 없어요.',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ),
              );
            }
            return Column(
              children: <Widget>[
                for (final NoteVersionSummary v in list)
                  _VersionItem(
                    versionNo: v.versionNo,
                    date: _formatVersionDate(v.createdAt),
                    title: v.title,
                    isSelected: _selectedVersionNo == v.versionNo,
                    onTap: () => setState(() => _selectedVersionNo = v.versionNo),
                    onRestore: _restoring ? null : () => _restore(v.versionNo),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object error, StackTrace stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                '버전 이력을 불러오지 못했어요.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ),
          ),
        ),
        if (_selectedVersionNo != null) ...[
          ConceptSectionLabel('버전 내용 (v$_selectedVersionNo)'),
          _VersionContent(noteId: widget.noteId, versionNo: _selectedVersionNo!),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

String _formatVersionDate(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${time.year}.${two(time.month)}.${two(time.day)} '
      '${two(time.hour)}:${two(time.minute)}';
}

/// 선택한 버전의 본문(마크다운)을 보여준다.
class _VersionContent extends ConsumerWidget {
  const _VersionContent({required this.noteId, required this.versionNo});

  final String noteId;
  final int versionNo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<NoteVersionDetail> detail =
        ref.watch(noteVersionDetailProvider((noteId, versionNo)));

    return detail.when(
      data: (NoteVersionDetail v) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              v.title,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            MarkdownBody(data: v.contentMd),
          ],
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) => Text(
        '버전 내용을 불러오지 못했어요.',
        style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
      ),
    );
  }
}

class _VersionItem extends StatelessWidget {
  const _VersionItem({
    required this.versionNo,
    required this.date,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.onRestore,
  });
  final int versionNo;
  final String date;
  final String title;
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
                borderRadius: BorderRadius.circular(AppRadius.sm - 4),
              ),
              child: Text(
                'v$versionNo',
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
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
