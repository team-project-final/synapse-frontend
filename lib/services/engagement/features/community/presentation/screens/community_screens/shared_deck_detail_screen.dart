part of '../community_screens.dart';

class SharedDeckDetailScreen extends ConsumerWidget {
  const SharedDeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(sharedContentProvider(deckId));

    return contentAsync.when(
      data: (deck) => _SharedContentDetail(
        content: deck,
        icon: Icons.style_outlined,
        copiedMessage: '덱이 내 라이브러리에 복사되었습니다',
      ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _ErrorState(
        message: '공유 덱을 불러오지 못했습니다',
        onRetry: () => ref.invalidate(sharedContentProvider(deckId)),
      ),
    );
  }
}

class _SharedContentDetail extends ConsumerStatefulWidget {
  const _SharedContentDetail({
    required this.content,
    required this.icon,
    required this.copiedMessage,
  });

  final SharedContent content;
  final IconData icon;
  final String copiedMessage;

  @override
  ConsumerState<_SharedContentDetail> createState() =>
      _SharedContentDetailState();
}

class _SharedContentDetailState extends ConsumerState<_SharedContentDetail> {
  bool _copying = false;
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final textTheme = Theme.of(context).textTheme;

    return ConceptPage(
      children: [
        Text(content.title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              size: 14,
              color: AppColors.stone400,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              'User ${content.ownerId}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(widget.icon, size: 14, color: AppColors.primaryAmber),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              content.contentType == SharedContentType.deck ? '덱' : '노트',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone500),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(
              Icons.download_outlined,
              size: 14,
              color: AppColors.stone400,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '${content.downloadCount}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
            ),
          ],
        ),
        if (content.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [for (final tag in content.tags) ConceptTag('#$tag')],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _copying
                    ? null
                    : () async {
                        setState(() => _copying = true);
                        try {
                          await ref
                              .read(communityApiProvider)
                              .forkSharedContent(content.shareToken);
                          ref.invalidate(
                            sharedContentProvider(content.shareToken),
                          );
                          if (context.mounted) {
                            AppToast.show(
                              context,
                              message: widget.copiedMessage,
                              type: ToastType.success,
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            AppToast.show(
                              context,
                              message: '복사에 실패했습니다',
                              type: ToastType.error,
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _copying = false);
                          }
                        }
                      },
                icon: _copying
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.copy_outlined),
                label: Text(_copying ? '복사 중' : '복사하기'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () async {
                await _showReportAndSubmit(
                  context,
                  ref,
                  targetTitle: content.title,
                  targetType: content.contentType == SharedContentType.deck
                      ? ReportTargetType.sharedDeck
                      : ReportTargetType.sharedNote,
                  targetId: content.id,
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('신고'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _deleting
              ? null
              : () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title: '공유 취소',
                    content: '이 콘텐츠의 공유를 취소하면 더 이상 검색되지 않습니다. 계속할까요?',
                    confirmLabel: '공유 취소',
                    isDestructive: true,
                  );
                  if (ok != true) return;
                  setState(() => _deleting = true);
                  try {
                    await ref.read(communityApiProvider).deleteSharedContent(
                          content.id,
                        );
                    ref.invalidate(sharedContentProvider(content.shareToken));
                    ref.invalidate(
                      sharedContentsProvider(
                        const SharedContentQuery(
                          contentType: SharedContentType.deck,
                        ),
                      ),
                    );
                    ref.invalidate(
                      sharedContentsProvider(
                        const SharedContentQuery(
                          contentType: SharedContentType.note,
                        ),
                      ),
                    );
                    if (context.mounted) {
                      AppToast.show(
                        context,
                        message: '공유가 취소되었습니다',
                        type: ToastType.success,
                      );
                      context.pop();
                    }
                  } catch (_) {
                    if (context.mounted) {
                      AppToast.show(
                        context,
                        message: '공유 취소에 실패했습니다',
                        type: ToastType.error,
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _deleting = false);
                    }
                  }
                },
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          icon: _deleting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline, size: 18),
          label: Text(_deleting ? '취소 중' : '공유 취소'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('설명', style: textTheme.titleMedium),
        const Divider(height: AppSpacing.md),
        ConceptCard(
          child: Text(
            content.description.isEmpty ? '설명이 없습니다.' : content.description,
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}
