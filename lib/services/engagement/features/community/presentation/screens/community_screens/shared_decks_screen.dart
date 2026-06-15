part of '../community_screens.dart';

// ── SharedDecksScreen (SCR-W-COMM-004) ──

class SharedDecksScreen extends ConsumerStatefulWidget {
  const SharedDecksScreen({super.key});

  @override
  ConsumerState<SharedDecksScreen> createState() => _SharedDecksScreenState();
}

class _SharedDecksScreenState extends ConsumerState<SharedDecksScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = '전체';
  bool _sharing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['전체', '최근', '인기'];
    final query = SharedContentQuery(
      query: _searchController.text,
      contentType: SharedContentType.deck,
    );
    // 공유 목록은 engagement search API가 가진 메타데이터 기준으로 조회한다.
    // 실제 덱 카드 내용은 상세 화면에서 learning shared-detail로 따로 가져온다.
    final decksAsync = ref.watch(sharedContentsProvider(query));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: StudySearchBar(
            hint: '공유 덱 검색…',
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
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
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: _sharing ? null : () => _showShareDeckDialog(query),
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
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: decksAsync.when(
            data: (decks) {
              // 백엔드가 아직 정렬 옵션을 받지 않으므로 화면에서는 받은 목록을
              // 실제 필드(downloadCount/createdAt) 기준으로만 정렬한다.
              final sortedDecks = _sortSharedContentList(
                decks,
                _selectedFilter,
              );
              return sortedDecks.isEmpty
                  ? const _EmptyGroupList(message: '공유 덱이 없습니다')
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: sortedDecks.length,
                      itemBuilder: (context, i) => _SharedDeckCard(
                        deck: sortedDecks[i],
                        query: query,
                      ),
                    );
            },
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
            error: (_, _) => _ErrorState(
              message: '공유 덱을 불러오지 못했습니다',
              onRetry: () => ref.invalidate(sharedContentsProvider(query)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showShareDeckDialog(SharedContentQuery query) async {
    final draft = await _SharedDeckCreateDialog.show(context);
    if (draft == null || !mounted) {
      return;
    }
    if (draft.deckId.isEmpty || draft.title.isEmpty) {
      AppToast.show(
        context,
        message: '덱 ID와 제목을 입력해주세요',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _sharing = true);
    final previousLevel = _currentGamificationLevel(ref);
    try {
      // workflow Step 5의 공유 등록 전에 learning이 원본 덱 공유 가능 여부를 검증한다.
      final shareable = await ref
          .read(communityLearningDeckApiProvider)
          .getShareableStatus(draft.deckId);
      if (!shareable.shareable) {
        if (mounted) {
          AppToast.show(
            context,
            message: shareable.reason.isEmpty
                ? '공유할 수 없는 덱입니다'
                : shareable.reason,
            type: ToastType.error,
          );
        }
        return;
      }

      // engagement는 shareToken과 검색용 메타데이터를 만들고,
      // 실제 덱 본문은 learning의 deckId를 통해 나중에 조회한다.
      await ref.read(communityApiProvider).shareContent(
            contentType: SharedContentType.deck,
            contentId: draft.deckId,
            title: draft.title,
            description: draft.description,
            tags: draft.tags,
          );
      ref.invalidate(sharedContentsProvider(query));
      if (mounted) {
        AppToast.show(
          context,
          message: '덱을 커뮤니티에 공유했습니다',
          type: ToastType.success,
        );
        await _refreshGamificationAfterEngagementAction(
          context: context,
          ref: ref,
          previousLevel: previousLevel,
          eventType: GamificationEventType.contentShared,
          sourceId: draft.deckId,
          sourceType: 'shared_deck',
          eventId: 'share-deck:${draft.deckId}',
          rewards: const ['덱 공유 보상'],
        );
      }
    } on DioException catch (error) {
      if (mounted) {
        AppToast.show(
          context,
          message: error.response?.statusCode == 403
              ? '덱 공유 권한이 없습니다'
              : '덱 공유 등록에 실패했습니다',
          type: ToastType.error,
        );
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: '덱 공유 등록에 실패했습니다',
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

class _SharedDeckCreateDialog extends StatelessWidget {
  const _SharedDeckCreateDialog({
    required this.deckIdController,
    required this.titleController,
    required this.descriptionController,
    required this.tagsController,
  });

  final TextEditingController deckIdController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;

  static Future<_SharedDeckDraft?> show(BuildContext context) async {
    final deckIdController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagsController = TextEditingController();
    final result = await showDialog<_SharedDeckDraft>(
      context: context,
      builder: (context) => _SharedDeckCreateDialog(
        deckIdController: deckIdController,
        titleController: titleController,
        descriptionController: descriptionController,
        tagsController: tagsController,
      ),
    );
    deckIdController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('공유 덱 등록'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: deckIdController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '덱 ID',
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
            _SharedDeckDraft(
              deckId: deckIdController.text.trim(),
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

class _SharedDeckDraft {
  const _SharedDeckDraft({
    required this.deckId,
    required this.title,
    required this.description,
    required this.tags,
  });

  final String deckId;
  final String title;
  final String description;
  final List<String> tags;
}

List<SharedContent> _sortSharedContentList(
  List<SharedContent> contents,
  String order,
) {
  // 원본 AsyncValue 데이터를 직접 바꾸지 않도록 복사본을 정렬한다.
  final sorted = contents.toList(growable: false);
  if (order == '인기' || order == '인기순') {
    sorted.sort((a, b) {
      final countCompare = b.downloadCount.compareTo(a.downloadCount);
      if (countCompare != 0) {
        return countCompare;
      }
      return _compareCreatedAtDesc(a, b);
    });
  } else if (order == '최근' || order == '최신순') {
    sorted.sort(_compareCreatedAtDesc);
  }
  return sorted;
}

int _compareCreatedAtDesc(SharedContent a, SharedContent b) {
  final aCreatedAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  final bCreatedAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  return bCreatedAt.compareTo(aCreatedAt);
}

class _SharedDeckCard extends ConsumerStatefulWidget {
  const _SharedDeckCard({required this.deck, required this.query});
  final SharedContent deck;
  final SharedContentQuery query;

  @override
  ConsumerState<_SharedDeckCard> createState() => _SharedDeckCardState();
}

class _SharedDeckCardState extends ConsumerState<_SharedDeckCard> {
  bool _copying = false;

  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () =>
            context.go(AppRoutes.communitySharedDeckDetailPath(deck.shareToken)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.style_outlined,
                size: 32,
                color: AppColors.primaryAmber,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                deck.title,
                style: textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'User ${deck.ownerId}',
                style: textTheme.bodySmall?.copyWith(color: AppColors.stone400),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.download_outlined,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${deck.downloadCount}회',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _copying
                      ? null
                      : () async {
                          setState(() => _copying = true);
                          final previousLevel = _currentGamificationLevel(ref);
                          try {
                            // learning이 실제 덱을 복사한 뒤 engagement가 공유 다운로드 수를 갱신한다.
                            await ref
                                .read(communityLearningDeckApiProvider)
                                .copyFromShare(
                                  deckId: deck.contentId,
                                  sharedContentId: deck.id,
                                  shareToken: deck.shareToken,
                                );
                            ref.invalidate(deckListNotifierProvider);
                            await ref
                                .read(communityApiProvider)
                                .forkSharedContent(deck.shareToken);
                            // 복사 후 상세/목록 캐시를 비워 다운로드 수와 내 덱 목록을 새로 받게 한다.
                            ref.invalidate(
                              sharedContentProvider(deck.shareToken),
                            );
                            ref.invalidate(
                              sharedContentsProvider(widget.query),
                            );
                            if (context.mounted) {
                              AppToast.show(
                                context,
                                message: '덱이 내 라이브러리에 복사되었습니다',
                                type: ToastType.success,
                              );
                              await _refreshGamificationAfterEngagementAction(
                                context: context,
                                ref: ref,
                                previousLevel: previousLevel,
                                eventType: GamificationEventType.contentCopied,
                                sourceId: deck.id,
                                sourceType: 'shared_deck',
                                eventId: 'copy-deck:${deck.shareToken}',
                                rewards: const ['공유 덱 복사 완료'],
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              AppToast.show(
                                context,
                                message: '덱 복사에 실패했습니다',
                                type: ToastType.error,
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _copying = false);
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: _copying
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('복사하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
