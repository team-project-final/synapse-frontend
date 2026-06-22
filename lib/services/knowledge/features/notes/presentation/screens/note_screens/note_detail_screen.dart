part of '../note_screens.dart';

// ── NoteDetailScreen (SCR-W-NOTE-003) ──

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final noteValue = ref.watch(noteDetailProvider(noteId));
    final backlinksValue = ref.watch(noteBacklinksProvider(noteId));

    Future<void> openWiki(String title) async {
      try {
        final page = await ref
            .read(knowledgeApiProvider)
            .searchNotes(query: title, limit: 1);
        if (!context.mounted || page.results.isEmpty) return;
        context.go(AppRoutes.noteDetailPath(page.results.first.noteId));
      } catch (_) {
        if (context.mounted) context.go(AppRoutes.search);
      }
    }

    return AppAsyncValueWidget<KnowledgeNote>(
      value: noteValue,
      loading: const AppLoadingWidget(label: '노트를 불러오는 중입니다.'),
      error: (error, _) => AppErrorWidget(
        message: '노트를 불러오지 못했습니다.',
        onRetry: () {
          ref.invalidate(noteDetailProvider(noteId));
          ref.invalidate(noteBacklinksProvider(noteId));
        },
      ),
      data: (note) {
        final mainContent = Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isMobile)
                      ConceptBackRow(
                        label: '라이브러리',
                        onTap: () => context.go(AppRoutes.notes),
                      ),
                    Text(
                      note.title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs + 2,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final tag in note.tags) ConceptTag('#$tag'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _WikiBody(
                      spans: _parseWikiSpans(
                        note.contentMd.isEmpty
                            ? note.contentPlain
                            : note.contentMd,
                      ),
                      onWikiTap: (title) => unawaited(openWiki(title)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ConceptAiEntry(
                      title: '✦ AI에게 이 노트 질문하기',
                      subtitle: '요약·퀴즈·심화 설명을 대화로 받아보세요',
                      onTap: () => context.go(AppRoutes.qa),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.go(AppRoutes.noteEditorPath(noteId)),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('편집'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.go(AppRoutes.noteVersionsPath(noteId)),
                            icon: const Icon(Icons.history, size: 18),
                            label: const Text('버전 이력'),
                          ),
                        ),
                      ],
                    ),
                    ConceptSectionLabel(
                      backlinksValue.maybeWhen(
                        data: (items) => '백링크 ${items.length}',
                        orElse: () => '백링크',
                      ),
                    ),
                    _BacklinksList(value: backlinksValue),
                  ],
                ),
              ],
            ),
          ),
        );

        if (isMobile) {
          return mainContent;
        }

        final backlinkPanel = Container(
          width: 280,
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                '백링크',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _BacklinksList(value: backlinksValue, compact: true),
            ],
          ),
        );

        return Row(
          children: [
            Expanded(child: mainContent),
            backlinkPanel,
          ],
        );
      },
    );
  }
}

/// 본문 인라인 조각 — 일반 텍스트 또는 위키링크.
class _Span {
  const _Span.text(this.value) : isWiki = false;
  const _Span.wiki(this.value) : isWiki = true;
  final String value;
  final bool isWiki;
}

List<_Span> _parseWikiSpans(String content) {
  if (content.isEmpty) return const [_Span.text('본문이 비어 있습니다.')];
  final spans = <_Span>[];
  final pattern = RegExp(r'\[\[([^\]]+)\]\]');
  var cursor = 0;
  for (final match in pattern.allMatches(content)) {
    if (match.start > cursor) {
      spans.add(_Span.text(content.substring(cursor, match.start)));
    }
    spans.add(_Span.wiki(match.group(1) ?? ''));
    cursor = match.end;
  }
  if (cursor < content.length) {
    spans.add(_Span.text(content.substring(cursor)));
  }
  return spans;
}

/// 위키링크가 본문 안에 인라인으로 박힌 노트 본문 (v1 `.detail-b` + `.wl`).
/// 위키링크는 primary 틴트 배경 + 탭 시 해당 노트로 이동.
class _WikiBody extends StatelessWidget {
  const _WikiBody({required this.spans, required this.onWikiTap});

  final List<_Span> spans;
  final ValueChanged<String> onWikiTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final base = textTheme.bodyLarge?.copyWith(
      height: 1.7,
      color: AppColors.text,
    );
    return Text.rich(
      TextSpan(
        children: [
          for (final s in spans)
            if (!s.isWiki)
              TextSpan(text: s.value, style: base)
            else
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () => onWikiTap(s.value),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '[[${s.value}]]',
                      style: base?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _BacklinkItem extends StatelessWidget {
  const _BacklinkItem({
    required this.title,
    required this.snippet,
    required this.onTap,
  });
  final String title;
  final String snippet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ConceptCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md - 2,
          vertical: AppSpacing.sm + 3,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text('📄', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: AppSpacing.sm + 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    snippet,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BacklinksList extends StatelessWidget {
  const _BacklinksList({required this.value, this.compact = false});

  final AsyncValue<List<KnowledgeNote>> value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppAsyncValueWidget<List<KnowledgeNote>>(
      value: value,
      isEmpty: (items) => items.isEmpty,
      loading: const AppLoadingWidget(label: '백링크를 불러오는 중입니다.'),
      empty: const AppEmptyState(
        icon: Icons.link_off_outlined,
        title: '연결된 백링크가 없습니다.',
      ),
      error: (error, _) => const AppErrorWidget(message: '백링크를 불러오지 못했습니다.'),
      data: (items) => Column(
        children: [
          for (final note in items)
            _BacklinkItem(
              title: note.title,
              snippet: note.snippet.isEmpty ? note.updatedLabel : note.snippet,
              onTap: () => context.go(AppRoutes.noteDetailPath(note.id)),
            ),
        ],
      ),
    );
  }
}
