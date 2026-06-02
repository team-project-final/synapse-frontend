part of '../note_screens.dart';

// ── NoteDetailScreen (SCR-W-NOTE-003) ──

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    // v1 ③: 본문 속 인라인 위키링크([[…]])가 탭 가능해야 한다.
    // TODO: 팀원 구현 — knowledge-svc 노트 상세 API 연동 (noteId: $noteId)
    void openWiki(String title) {
      // mock — 위키링크 타깃 노트로 이동(실제 ID는 백엔드 연동 시 해석)
      context.go(AppRoutes.noteDetailPath('2'));
    }

    final mainContent = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        // ListView가 tight 폭을 자식에게 전달하도록 maxWidth를 정의한다.
        // (Center+loose 제약 + stretch 조합은 자식 폭을 intrinsic으로 잘못
        // 계산해 오버플로를 유발하므로 Align+고정폭 ListView로 분리)
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
                // Title + tags
                Text(
                  '정규화 기법 (Regularization)',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // TODO: 팀원 구현 — 노트 태그 동적 연동
                const Wrap(
                  spacing: AppSpacing.xs + 2,
                  runSpacing: AppSpacing.xs,
                  children: [ConceptTag('#머신러닝'), ConceptTag('#딥러닝')],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => ShareDialog.show(
                      context,
                      targetTitle: '정규화 기법 (Regularization)',
                    ),
                    icon: const Icon(Icons.ios_share, size: 18),
                    label: const Text('공유하기'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // 본문 — 인라인 위키링크([[…]])가 본문 안에서 탭 가능.
                _WikiBody(
                  spans: const [
                    _Span.text('과적합 방지를 위한 기법들을 정리한다. 대표적으로 '),
                    _Span.wiki('Lasso'),
                    _Span.text('(L1)와 '),
                    _Span.wiki('Ridge'),
                    _Span.text('(L2) 정규화가 있다.\n\nL1은 '),
                    _Span.wiki('가중치'),
                    _Span.text(
                      '를 0으로 만들어 sparse 솔루션을 유도하고, L2는 가중치를 작게 유지한다. '
                      '신경망에서는 ',
                    ),
                    _Span.wiki('드롭아웃'),
                    _Span.text('이 정규화 역할을 하며, 이는 '),
                    _Span.wiki('과적합'),
                    _Span.text('을 효과적으로 줄인다.'),
                  ],
                  onWikiTap: openWiki,
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
                // 백링크 — 📄 아이콘 + 제목 + 인용 스니펫 (v1 `.backlinks`).
                const ConceptSectionLabel('백링크 4'),
                // TODO: 팀원 구현 — knowledge-svc 백링크 API 연동
                _BacklinkItem(
                  title: '과적합',
                  snippet: '"…해결: ML 정규화 기법, 교차검증."',
                  onTap: () => context.go(AppRoutes.noteDetailPath('2')),
                ),
                _BacklinkItem(
                  title: '드롭아웃',
                  snippet: '"…ML 정규화 기법의 한 종류로…"',
                  onTap: () => context.go(AppRoutes.noteDetailPath('3')),
                ),
                _BacklinkItem(
                  title: '교차검증',
                  snippet: '"…ML 정규화 기법과 함께 사용…"',
                  onTap: () => context.go(AppRoutes.noteDetailPath('4')),
                ),
                _BacklinkItem(
                  title: '경사하강법',
                  snippet: '"…정규화 항을 손실에 더해…"',
                  onTap: () => context.go(AppRoutes.noteDetailPath('5')),
                ),
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
          // TODO: 팀원 구현 — knowledge-svc 백링크 API 연동
          _BacklinkItem(
            title: '드롭아웃 기법',
            snippet: '과적합 방지를 위한 기법',
            onTap: () => context.go(AppRoutes.noteDetailPath('2')),
          ),
          _BacklinkItem(
            title: 'Ridge vs Lasso 비교',
            snippet: 'L2 정규화 비교 분석',
            onTap: () => context.go(AppRoutes.noteDetailPath('3')),
          ),
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
}

/// 본문 인라인 조각 — 일반 텍스트 또는 위키링크.
class _Span {
  const _Span.text(this.value) : isWiki = false;
  const _Span.wiki(this.value) : isWiki = true;
  final String value;
  final bool isWiki;
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
