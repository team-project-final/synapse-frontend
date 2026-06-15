part of '../community_screens.dart';

class SharedDeckDetailScreen extends ConsumerWidget {
  const SharedDeckDetailScreen({
    required this.deckId,
    this.sharedContentId,
    this.shareToken,
    super.key,
  });

  final String deckId;
  final String? sharedContentId;
  final String? shareToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // dev의 learning 공유 상세 경로는 deckId + query params를 넘기고,
    // engagement 공유 목록은 shareToken을 path id처럼 넘긴다. 둘 다 수용한다.
    final contentKey = shareToken ?? deckId;
    final contentAsync = ref.watch(sharedContentProvider(contentKey));

    return contentAsync.when(
      data: (deck) => _SharedContentDetail(
        content: deck,
        icon: Icons.style_outlined,
        copiedMessage: '덱이 내 라이브러리에 복사되었습니다',
      ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, _) => _ErrorState(
        message: '공유 덱을 불러오지 못했습니다',
        onRetry: () => ref.invalidate(sharedContentProvider(contentKey)),
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
    // engagement의 공유글(content)에서 learning 덱 id와 검증용 공유 정보를 꺼내
    // learning shared-detail 요청에 필요한 query key를 만든다.
    final deckDetailQuery = content.contentType == SharedContentType.deck
        ? SharedDeckDetailQuery(
            deckId: content.contentId,
            sharedContentId: content.id,
            shareToken: content.shareToken,
          )
        : null;
    final deckDetailAsync = deckDetailQuery == null
        ? null
        : ref.watch(sharedDeckDetailProvider(deckDetailQuery));

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
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '${content.downloadCount}',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
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
                        final previousLevel = _currentGamificationLevel(ref);
                        try {
                          if (content.contentType == SharedContentType.deck) {
                            // 1. learning-svc가 실제 덱과 카드들을 내 라이브러리로 복사한다.
                            await ref
                                .read(communityLearningDeckApiProvider)
                                .copyFromShare(
                                  deckId: content.contentId,
                                  sharedContentId: content.id,
                                  shareToken: content.shareToken,
                                );
                            ref.invalidate(deckListNotifierProvider);
                          } else {
                            // 1. knowledge-svc가 실제 노트를 내 라이브러리로 복사한다.
                            await ref.read(dioProvider).post<Map<String, dynamic>>(
                              '/api/v1/notes/${content.contentId}/copy-from-share',
                              data: <String, dynamic>{
                                'sharedContentId': content.id,
                                'shareToken': content.shareToken,
                              },
                            );
                          }
                          // 2. engagement-svc는 공유 메타데이터를 fork하고 원본 다운로드 수를 증가시킨다.
                          await ref
                              .read(communityApiProvider)
                              .forkSharedContent(content.shareToken);
                          ref.invalidate(
                            sharedContentProvider(content.shareToken),
                          );
                          ref.invalidate(
                            sharedContentsProvider(
                              SharedContentQuery(
                                contentType: content.contentType,
                              ),
                            ),
                          );
                          if (context.mounted) {
                            AppToast.show(
                              context,
                              message: widget.copiedMessage,
                              type: ToastType.success,
                            );
                            await _refreshGamificationAfterEngagementAction(
                              context: context,
                              ref: ref,
                              previousLevel: previousLevel,
                              eventType: GamificationEventType.contentCopied,
                              sourceId: content.id,
                              sourceType:
                                  content.contentType == SharedContentType.deck
                                      ? 'shared_deck'
                                      : 'shared_note',
                              eventId:
                                  'copy-${content.contentType.apiValue.toLowerCase()}:${content.shareToken}',
                              rewards: content.contentType ==
                                      SharedContentType.deck
                                  ? const ['공유 덱 복사 완료']
                                  : const ['공유 노트 복사 완료'],
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
        if (deckDetailAsync != null) ...[
          const SizedBox(height: AppSpacing.lg),
          // learning에서 받은 실제 카드 내용을 engagement 메타데이터 아래에 붙여 보여준다.
          _SharedDeckLearningSection(
            detailAsync: deckDetailAsync,
            onRetry: () => ref.invalidate(
              sharedDeckDetailProvider(deckDetailQuery!),
            ),
          ),
        ],
      ],
    );
  }
}

class _SharedDeckLearningSection extends StatelessWidget {
  const _SharedDeckLearningSection({
    required this.detailAsync,
    required this.onRetry,
  });

  final AsyncValue<SharedDeckDetail> detailAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return detailAsync.when(
      data: (detail) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('덱 카드', style: textTheme.titleMedium),
              ),
              Text(
                '${detail.cardCount}장',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.stone400,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.md),
          if (detail.cards.isEmpty)
            const ConceptCard(child: Text('카드가 없습니다.'))
          else
            ...detail.cards.map((card) => _SharedDeckCardPreview(card)),
        ],
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
      error: (_, _) => _ErrorState(
        message: '덱 상세 카드를 불러오지 못했습니다',
        onRetry: onRetry,
      ),
    );
  }
}

class _SharedDeckCardPreview extends StatelessWidget {
  const _SharedDeckCardPreview(this.card);

  final SharedDeckCard card;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ConceptCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.frontContent.isEmpty ? '앞면 내용 없음' : card.frontContent,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              card.backContent.isEmpty ? '뒷면 내용 없음' : card.backContent,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.stone500,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
