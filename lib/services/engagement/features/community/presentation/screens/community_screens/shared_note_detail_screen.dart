part of '../community_screens.dart';

// ── SharedNoteDetailScreen (SCR-W-COMM-006) ──

class SharedNoteDetailScreen extends ConsumerStatefulWidget {
  const SharedNoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<SharedNoteDetailScreen> createState() =>
      _SharedNoteDetailScreenState();
}

class _SharedNoteDetailScreenState
    extends ConsumerState<SharedNoteDetailScreen> {
  bool _forking = false;
  bool _reporting = false;

  @override
  Widget build(BuildContext context) {
    final detailValue = ref.watch(sharedContentDetailProvider(widget.noteId));

    return AppAsyncValueWidget<SharedContent>(
      value: detailValue,
      loading: const AppLoadingWidget(label: '공유 노트 상세를 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '공유 노트 상세를 불러오지 못했습니다.',
        onRetry: () =>
            ref.invalidate(sharedContentDetailProvider(widget.noteId)),
      ),
      data: (note) => _buildDetail(context, note),
    );
  }

  Widget _buildDetail(BuildContext context, SharedContent note) {
    final textTheme = Theme.of(context).textTheme;

    return ConceptPage(
      children: [
        Text(note.title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaChip(icon: Icons.person_outline, label: note.ownerLabel),
            _MetaChip(icon: Icons.schedule, label: note.createdLabel),
            _MetaChip(
              icon: Icons.download_outlined,
              label: '${_formatCount(note.downloadCount)}회 복사',
            ),
          ],
        ),
        if (note.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [for (final tag in note.tags) ConceptTag('#$tag')],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _forking ? null : () => _fork(note),
                icon: _forking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.copy_outlined),
                label: const Text('복사하기'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              onPressed: _reporting ? null : () => _report(note),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text('신고'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('본문 미리보기', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        ConceptCard(
          child: Text(
            note.description.isEmpty ? '미리보기 설명이 없습니다.' : note.description,
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('공유 정보', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        ConceptCard(
          child: Column(
            children: [
              _InfoRow(label: '공유 ID', value: note.id),
              _InfoRow(label: '공유 토큰', value: note.shareToken),
              _InfoRow(label: '원본 노트 ID', value: note.contentId),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _fork(SharedContent note) async {
    setState(() => _forking = true);
    try {
      await ref.read(engagementApiProvider).forkSharedContent(note.shareToken);
      ref.invalidate(sharedContentDetailProvider(widget.noteId));
      if (mounted) {
        AppToast.show(
          context,
          message: '노트가 내 라이브러리에 복사되었습니다',
          type: ToastType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: '노트를 복사하지 못했습니다',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _forking = false);
    }
  }

  Future<void> _report(SharedContent note) async {
    final result = await ReportDialog.show(context, targetTitle: note.title);
    if (result == null) return;
    setState(() => _reporting = true);
    final detail = result['detail']?.trim();
    final reason = [
      result['reason'] ?? '',
      if (detail != null && detail.isNotEmpty) detail,
    ].where((part) => part.isNotEmpty).join(' · ');
    try {
      await ref
          .read(engagementApiProvider)
          .createReport(
            targetType: 'SHARED_NOTE',
            targetId: note.id,
            reason: reason,
          );
      if (mounted) {
        AppToast.show(context, message: '신고가 접수되었습니다', type: ToastType.success);
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: '신고를 접수하지 못했습니다',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _reporting = false);
    }
  }
}
