part of '../community_screens.dart';

// ── SharedDeckDetailScreen (SCR-W-COMM-005) ──

class SharedDeckDetailScreen extends ConsumerStatefulWidget {
  const SharedDeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<SharedDeckDetailScreen> createState() =>
      _SharedDeckDetailScreenState();
}

class _SharedDeckDetailScreenState
    extends ConsumerState<SharedDeckDetailScreen> {
  bool _forking = false;
  bool _reporting = false;

  @override
  Widget build(BuildContext context) {
    final detailValue = ref.watch(sharedContentDetailProvider(widget.deckId));

    return AppAsyncValueWidget<SharedContent>(
      value: detailValue,
      loading: const AppLoadingWidget(label: '공유 덱 상세를 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '공유 덱 상세를 불러오지 못했습니다.',
        onRetry: () =>
            ref.invalidate(sharedContentDetailProvider(widget.deckId)),
      ),
      data: (deck) => _buildDetail(context, deck),
    );
  }

  Widget _buildDetail(BuildContext context, SharedContent deck) {
    final textTheme = Theme.of(context).textTheme;

    return ConceptPage(
      children: [
        Text(deck.title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaChip(icon: Icons.person_outline, label: deck.ownerLabel),
            _MetaChip(
              icon: Icons.download_outlined,
              label: '${_formatCount(deck.downloadCount)}회 복사',
            ),
            _MetaChip(icon: Icons.schedule, label: deck.createdLabel),
          ],
        ),
        if (deck.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [for (final tag in deck.tags) ConceptTag('#$tag')],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _forking ? null : () => _fork(deck),
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
              onPressed: _reporting ? null : () => _report(deck),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text('신고'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('설명', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        ConceptCard(
          child: Text(
            deck.description.isEmpty ? '설명이 없습니다.' : deck.description,
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('공유 정보', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        ConceptCard(
          child: Column(
            children: [
              _InfoRow(label: '공유 ID', value: deck.id),
              _InfoRow(label: '공유 토큰', value: deck.shareToken),
              _InfoRow(label: '원본 덱 ID', value: deck.contentId),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _fork(SharedContent deck) async {
    setState(() => _forking = true);
    try {
      await ref.read(engagementApiProvider).forkSharedContent(deck.shareToken);
      ref.invalidate(sharedContentDetailProvider(widget.deckId));
      if (mounted) {
        AppToast.show(
          context,
          message: '덱이 내 라이브러리에 복사되었습니다',
          type: ToastType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, message: '덱을 복사하지 못했습니다', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _forking = false);
    }
  }

  Future<void> _report(SharedContent deck) async {
    final result = await ReportDialog.show(context, targetTitle: deck.title);
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
            targetType: 'SHARED_DECK',
            targetId: deck.id,
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.stone400),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
