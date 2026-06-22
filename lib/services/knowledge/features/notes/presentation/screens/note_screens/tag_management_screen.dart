part of '../note_screens.dart';

// ── TagManagementScreen (SCR-W-NOTE-005) ──

class TagManagementScreen extends ConsumerStatefulWidget {
  const TagManagementScreen({super.key});

  @override
  ConsumerState<TagManagementScreen> createState() =>
      _TagManagementScreenState();
}

class _TagManagementScreenState extends ConsumerState<TagManagementScreen> {
  final _searchController = TextEditingController();
  int _selectedColorIndex = 5;

  static const _presetColors = AppColors.tagPalette;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTagMergeDialog(BuildContext context) {
    final tags = ref
        .read(popularTagsProvider)
        .when(
          data: (items) => items,
          loading: () => const <KnowledgeTagStat>[],
          error: (_, _) => const <KnowledgeTagStat>[],
        );
    final tagNames = tags.map((t) => t.tag).toList(growable: false);
    if (tagNames.isEmpty) return;
    String? sourceTag = tagNames.first;
    String? targetTag = tagNames.length > 1 ? tagNames[1] : tagNames.first;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('태그 병합'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('원본 태그 (병합할 태그)'),
              const SizedBox(height: AppSpacing.xs),
              DropdownButton<String>(
                value: sourceTag,
                isExpanded: true,
                items: tagNames
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setDialogState(() => sourceTag = v),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('대상 태그 (병합 대상)'),
              const SizedBox(height: AppSpacing.xs),
              DropdownButton<String>(
                value: targetTag,
                isExpanded: true,
                items: tagNames
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setDialogState(() => targetTag = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('태그 병합 API 계약이 필요합니다.')),
                );
              },
              child: const Text('병합'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tagsValue = ref.watch(popularTagsProvider);

    return Stack(
      children: [
        ConceptPage(
          children: [
            const ConceptViewHead(title: '태그 관리'),
            ConceptSearchBar(
              hint: '태그 검색…',
              value: _searchController.text,
              onTap: () {},
            ),
            // 검색 입력(숨김 컨트롤러) — 데모상 비표시이나 mock 필터 유지
            Offstage(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const ConceptSectionLabel('새 태그 색상', topGap: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm + 2,
              runSpacing: AppSpacing.sm + 2,
              children: List.generate(_presetColors.length, (i) {
                final isSelected = _selectedColorIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = i),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _presetColors[i],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.text, width: 2.5)
                          : Border.all(color: AppColors.border),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => _showTagMergeDialog(context),
              icon: const Icon(Icons.merge_type, size: 18),
              label: const Text('태그 병합'),
            ),
            const ConceptSectionLabel('모든 태그'),
            AppAsyncValueWidget<List<KnowledgeTagStat>>(
              value: tagsValue,
              isEmpty: (items) => items.isEmpty,
              loading: const AppLoadingWidget(label: '태그를 불러오는 중입니다.'),
              empty: const AppEmptyState(
                icon: Icons.sell_outlined,
                title: '아직 태그가 없습니다.',
              ),
              error: (error, _) => AppErrorWidget(
                message: '태그를 불러오지 못했습니다.',
                onRetry: () => ref.invalidate(popularTagsProvider),
              ),
              data: (tags) {
                final filtered = tags
                    .where((t) => t.tag.contains(_searchController.text))
                    .toList(growable: false);
                return Column(
                  children: [
                    for (final tag in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ConceptCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 2,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.tag,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  tag.tag,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${tag.count}개 노트',
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('태그 삭제 API 계약이 필요합니다.'),
                                    ),
                                  );
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
          ],
        ),
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('태그 생성 API 계약이 필요합니다.')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('태그 추가'),
          ),
        ),
      ],
    );
  }
}
