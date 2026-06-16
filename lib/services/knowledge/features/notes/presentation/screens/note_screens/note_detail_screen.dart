part of '../note_screens.dart';

// ── NoteDetailScreen (SCR-W-NOTE-003) ──

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // knowledge-svc 노트 상세 API(GET /api/v1/notes/{id}) 연동
    final AsyncValue<Note> asyncNote = ref.watch(noteDetailProvider(noteId));
    return asyncNote.when(
      data: (Note note) => _NoteDetailView(noteId: noteId, note: note),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => _DetailError(
        onRetry: () => ref.invalidate(noteDetailProvider(noteId)),
        onBack: () => context.go(AppRoutes.notes),
      ),
    );
  }
}

class _NoteDetailView extends ConsumerWidget {
  const _NoteDetailView({required this.noteId, required this.note});

  final String noteId;
  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final AsyncValue<List<Note>> backlinks = ref.watch(backlinksProvider(noteId));
    final AsyncValue<List<Note>> outlinks = ref.watch(outlinksProvider(noteId));

    final mainContent = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        // ListView가 tight 폭을 자식에게 전달하도록 maxWidth를 정의한다.
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
                // Title
                Text(
                  note.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Tags — 노트 태그 동적 연동
                if (note.tags.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.xs + 2,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final String tag in note.tags) ConceptTag('#$tag'),
                    ],
                  ),
                const SizedBox(height: AppSpacing.md),
                // 본문 — contentMd 마크다운 렌더
                // TODO: 팀원 구현 — 본문 내 위키링크([[…]]) 탭 이동 (5단계)
                MarkdownBody(
                  data: note.contentMd,
                  selectable: true,
                ),
                const SizedBox(height: AppSpacing.md),
                // AI 진입
                ConceptAiEntry(
                  title: '✦ AI에게 이 노트 질문하기',
                  subtitle: '요약·퀴즈·심화 설명을 대화로 받아보세요',
                  onTap: () => context.go(AppRoutes.qa),
                ),
                const SizedBox(height: AppSpacing.md),
                // Action row
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
                // 백링크 — GET /notes/{id}/backlinks
                ConceptSectionLabel(_linkLabel('백링크', backlinks)),
                ..._buildLinkItems(context, backlinks,
                    emptyText: '연결된 백링크가 없어요.', errorText: '백링크를 불러오지 못했어요.'),
                // 아웃링크 — GET /notes/{id}/outlinks (이 노트가 가리키는 노트)
                ConceptSectionLabel(_linkLabel('아웃링크', outlinks)),
                ..._buildLinkItems(context, outlinks,
                    emptyText: '연결된 아웃링크가 없어요.', errorText: '아웃링크를 불러오지 못했어요.'),
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
            _linkLabel('백링크', backlinks),
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // knowledge-svc 백링크 API 연동
          ..._buildLinkItems(context, backlinks,
              emptyText: '연결된 백링크가 없어요.', errorText: '백링크를 불러오지 못했어요.'),
          const SizedBox(height: AppSpacing.md),
          Text(
            _linkLabel('아웃링크', outlinks),
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._buildLinkItems(context, outlinks,
              emptyText: '연결된 아웃링크가 없어요.', errorText: '아웃링크를 불러오지 못했어요.'),
        ],
      ),
    );

    return Row(
      children: [
        Expanded(child: mainContent),
        backlinkPanel,
      ],
    );
  }

  String _linkLabel(String prefix, AsyncValue<List<Note>> links) {
    return links.maybeWhen(
      data: (List<Note> notes) => '$prefix ${notes.length}',
      orElse: () => prefix,
    );
  }

  /// 백링크/아웃링크 공용 — 링크 노트 목록을 _BacklinkItem 으로 렌더한다.
  List<Widget> _buildLinkItems(
    BuildContext context,
    AsyncValue<List<Note>> links, {
    required String emptyText,
    required String errorText,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return links.when(
      data: (List<Note> notes) {
        if (notes.isEmpty) {
          return <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                emptyText,
                style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
              ),
            ),
          ];
        }
        return <Widget>[
          for (final Note n in notes)
            _BacklinkItem(
              title: n.title,
              snippet: _linkSnippet(n.contentPlain),
              onTap: () => context.go(AppRoutes.noteDetailPath(n.id)),
            ),
        ];
      },
      loading: () => const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ],
      error: (Object error, StackTrace stackTrace) => <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            errorText,
            style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  static String _linkSnippet(String contentPlain) {
    final String trimmed = contentPlain.trim();
    if (trimmed.length <= 50) {
      return trimmed;
    }
    return '${trimmed.substring(0, 50)}…';
  }
}

/// 상세 로딩 실패 시 재시도/뒤로가기 UI.
class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry, required this.onBack});

  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '노트를 불러오지 못했어요.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton(onPressed: onBack, child: const Text('라이브러리')),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('다시 시도'),
              ),
            ],
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
                borderRadius: BorderRadius.circular(AppRadius.sm - 4),
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
