import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

// ── Mock data ──

class _MockNote {
  const _MockNote({
    required this.id,
    required this.title,
    required this.snippet,
    required this.tags,
    required this.timeAgo,
    this.backlinks,
  });
  final String id;
  final String title;
  final String snippet;
  final List<String> tags;
  final String timeAgo;
  final int? backlinks;
}

const _mockNotes = [
  _MockNote(
    id: '1',
    title: '정규화 기법 (Regularization)',
    snippet: 'L1/L2 정규화는 과적합을 방지하기 위한 기법입니다. L1은 Lasso, L2는 Ridge라고 불립니다.',
    tags: ['머신러닝', '딥러닝'],
    timeAgo: '2시간 전',
    backlinks: 5,
  ),
  _MockNote(
    id: '2',
    title: '동적 프로그래밍 기초',
    snippet: '메모이제이션과 타뷸레이션을 사용하여 중복 계산을 피하는 알고리즘 설계 기법입니다.',
    tags: ['알고리즘', '코딩'],
    timeAgo: '어제',
  ),
  _MockNote(
    id: '3',
    title: 'AWS S3 버킷 정책',
    snippet: 'IAM 정책과 버킷 정책의 차이점 및 교차 계정 접근 설정 방법을 다룹니다.',
    tags: ['AWS', '클라우드'],
    timeAgo: '3일 전',
  ),
];

// ── NoteListScreen (SCR-W-NOTE-001) ──

class NoteListScreen extends ConsumerStatefulWidget {
  const NoteListScreen({super.key});

  @override
  ConsumerState<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends ConsumerState<NoteListScreen> {
  String _selectedFilter = '전체';
  String _sortOrder = '최근 수정';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final filters = ['전체', '머신러닝', '딥러닝', '알고리즘', 'AWS'];

    return Stack(
      children: [
        ConceptPage(
          children: [
            const ConceptViewHead(title: '라이브러리', meta: '노트 24'),
            // Search bar (탭하면 검색 화면) — 데모용
            // TODO: 팀원 구현 — knowledge-svc 검색 API 연동
            ConceptSearchBar(
              hint: '노트 검색…',
              onTap: () => context.go(AppRoutes.search),
            ),
            const SizedBox(height: AppSpacing.md),
            // Filter pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in filters) ...[
                    ConceptFilterPill(
                      label: f,
                      selected: _selectedFilter == f,
                      onTap: () => setState(() => _selectedFilter = f),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Sort order
            Row(
              children: [
                Text(
                  '정렬',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                DropdownButton<String>(
                  value: _sortOrder,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                  items: const [
                    DropdownMenuItem(value: '최근 수정', child: Text('최근 수정')),
                    DropdownMenuItem(value: '제목순', child: Text('제목순')),
                    DropdownMenuItem(value: '생성일', child: Text('생성일')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _sortOrder = v);
                  },
                ),
              ],
            ),
            const ConceptSectionLabel('최근 노트', topGap: AppSpacing.md),
            // Note list
            // TODO: 팀원 구현 — knowledge-svc 노트 목록 API 연동
            ConceptResponsiveGrid(
              isWide: isWide,
              children: [for (final note in _mockNotes) _NoteCard(note: note)],
            ),
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
          ],
        ),
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: FloatingActionButton.extended(
            onPressed: () => context.go(AppRoutes.noteEditorPath('new')),
            icon: const Icon(Icons.add),
            label: const Text('새 노트'),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final _MockNote note;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: ConceptCard(
        onTap: () => context.go(AppRoutes.noteDetailPath(note.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              note.snippet,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.xs + 2,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final tag in note.tags) ConceptTag('#$tag'),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  note.backlinks != null
                      ? '백링크 ${note.backlinks}'
                      : note.timeAgo,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

// ── NoteEditorScreen (split view) ──

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final TabController _tabController;
  String _markdown = '';

  /// `[[` 위키링크 자동완성 후보 (mock — v1 목업의 autocomplete 드롭다운).
  /// TODO: 팀원 구현 — knowledge-svc 노트 제목 검색으로 후보 동적 로드
  static const _wikiCandidates = [
    ('어텐션 메커니즘', '#딥러닝'),
    ('어텐션 스코어', '새 노트'),
    ('인코더-디코더', '#딥러닝'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      setState(() => _markdown = _controller.text);
    });
  }

  /// 커서 앞 텍스트가 닫히지 않은 `[[…` 패턴이면 자동완성 쿼리를 돌려준다.
  /// (대괄호 짝이 맞으면 null → 드롭다운 숨김)
  String? get _wikiQuery {
    final sel = _controller.selection;
    final caret = sel.isValid ? sel.baseOffset : _controller.text.length;
    if (caret < 0) return null;
    final before = _controller.text.substring(
      0,
      caret.clamp(0, _controller.text.length),
    );
    final open = before.lastIndexOf('[[');
    if (open == -1) return null;
    // `[[` 이후 구간에 `]]` 가 없어야 "입력 중"으로 간주.
    final after = before.substring(open + 2);
    if (after.contains(']]')) return null;
    return after;
  }

  void _acceptWiki(String title) {
    final sel = _controller.selection;
    final caret = sel.isValid ? sel.baseOffset : _controller.text.length;
    final text = _controller.text;
    final open = text.substring(0, caret).lastIndexOf('[[');
    if (open == -1) return;
    final newText = text.replaceRange(open, caret, '[[$title]]');
    final newCaret = open + title.length + 4;
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCaret),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _insertMarkdown(String syntax) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final newText = text.replaceRange(start, end, syntax);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + syntax.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              // 좁은 폭에서도 오버플로 없이 가로 스크롤되는 포맷 버튼 그룹.
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ToolbarButton(
                        icon: Icons.format_bold,
                        tooltip: 'Bold',
                        onTap: () => _insertMarkdown('**텍스트**'),
                      ),
                      _ToolbarButton(
                        icon: Icons.format_italic,
                        tooltip: 'Italic',
                        onTap: () => _insertMarkdown('*텍스트*'),
                      ),
                      _ToolbarButton(
                        icon: Icons.title,
                        tooltip: 'Heading 1',
                        onTap: () => _insertMarkdown('# '),
                      ),
                      _ToolbarButton(
                        icon: Icons.text_fields,
                        tooltip: 'Heading 2',
                        onTap: () => _insertMarkdown('## '),
                      ),
                      _ToolbarButton(
                        icon: Icons.link,
                        tooltip: 'Link',
                        onTap: () => _insertMarkdown('[['),
                      ),
                      _ToolbarButton(
                        icon: Icons.code,
                        tooltip: 'Code',
                        onTap: () => _insertMarkdown('`코드`'),
                      ),
                    ],
                  ),
                ),
              ),
              // 자동저장 인디케이터
              const Icon(Icons.circle, size: 8, color: AppColors.success),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '저장됨',
                style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
              // TODO: 팀원 구현 — 자동저장 상태 연동
              const SizedBox(width: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  if (widget.noteId == 'new') {
                    // TODO: 팀원 구현 — knowledge-svc POST /notes API 호출 후 생성된 noteId 상세로 이동
                    context.go(AppRoutes.notes);
                  } else {
                    // TODO: 팀원 구현 — knowledge-svc PUT /notes/:noteId API 호출
                    context.go(AppRoutes.noteDetailPath(widget.noteId));
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(widget.noteId == 'new' ? '등록' : '저장'),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: isMobile
              ? _buildMobileTabView(textTheme)
              : _buildDesktopSplitView(textTheme),
        ),
      ],
    );
  }

  /// 편집 영역 = 마크다운 입력 + `[[` 자동완성 드롭다운 + AI 정리 제안 카드.
  /// v1 목업 ④의 핵심 디테일을 데스크탑/모바일 양쪽에서 재사용한다.
  Widget _buildEditorPane(TextTheme textTheme, {required bool expandField}) {
    final query = _wikiQuery;
    final field = TextField(
      controller: _controller,
      maxLines: expandField ? null : 6,
      minLines: expandField ? null : 6,
      expands: expandField,
      textAlignVertical: TextAlignVertical.top,
      style: textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
      decoration: const InputDecoration(
        hintText: '마크다운으로 작성하세요…  [[ 로 위키링크',
        border: InputBorder.none,
      ),
      // TODO: 팀원 구현 — knowledge-svc API 연동, 위키링크 파싱
    );

    final extras = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (query != null)
          _WikiAutocomplete(
            query: query,
            candidates: _wikiCandidates,
            onSelect: _acceptWiki,
          ),
        const SizedBox(height: AppSpacing.md),
        ConceptGradientCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SynapseOrb(size: 38, glyphScale: 0.46),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✦ AI 정리 제안',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '이 노트를 3개 섹션으로 구조화하고 누락된 위키링크 「인코더-디코더」를 제안할게요.',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton(
                      onPressed: () {
                        // TODO: 팀원 구현 — AI 노트 정리 제안 API 연동
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('제안 보기 →'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // expandField=true(데스크탑 split): 입력칸이 남는 높이를 채우고 extras는 하단 고정.
    // expandField=false(모바일 탭): 전체를 스크롤시켜 키보드/오버플로 회피.
    if (expandField) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: field),
            extras,
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [field, extras],
    );
  }

  Widget _buildDesktopSplitView(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(child: _buildEditorPane(textTheme, expandField: true)),
        const VerticalDivider(width: 1, color: AppColors.border),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _markdown.isEmpty
                ? Center(
                    child: Text(
                      '미리보기가 여기에 표시됩니다',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  )
                : SingleChildScrollView(child: MarkdownBody(data: _markdown)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabView(TextTheme textTheme) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '편집'),
            Tab(text: '미리보기'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEditorPane(textTheme, expandField: false),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _markdown.isEmpty
                    ? Center(
                        child: Text(
                          '미리보기가 여기에 표시됩니다',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: MarkdownBody(data: _markdown),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      color: AppColors.muted,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// `[[` 위키링크 자동완성 드롭다운. v1 목업 `.autocomplete` — primary 보더 +
/// 헤더 + 후보 항목(첫 항목 강조). 쿼리로 후보를 필터링한다.
class _WikiAutocomplete extends StatelessWidget {
  const _WikiAutocomplete({
    required this.query,
    required this.candidates,
    required this.onSelect,
  });

  final String query;
  final List<(String, String)> candidates;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = query.trim();
    final filtered = q.isEmpty
        ? candidates
        : candidates.where((c) => c.$1.contains(q)).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Row(
              children: [
                Text(
                  '[[',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '위키링크 자동완성',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < filtered.length; i++)
            Material(
              color: i == 0
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm - 3),
              child: InkWell(
                onTap: () => onSelect(filtered[i].$1),
                borderRadius: BorderRadius.circular(AppRadius.sm - 3),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm + 1),
                  child: Row(
                    children: [
                      Text(
                        '[[',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          filtered[i].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        filtered[i].$2,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── NoteVersionsScreen (SCR-W-NOTE-004) ──

class NoteVersionsScreen extends ConsumerStatefulWidget {
  const NoteVersionsScreen({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<NoteVersionsScreen> createState() => _NoteVersionsScreenState();
}

class _NoteVersionsScreenState extends ConsumerState<NoteVersionsScreen> {
  String? _selectedVersion;

  // TODO: 팀원 구현 — knowledge-svc 버전 이력 API 연동
  final _mockVersions = [
    {'version': 'v3', 'date': '2026-05-20 14:32', 'desc': 'L2 정규화 설명 추가'},
    {'version': 'v2', 'date': '2026-05-19 09:15', 'desc': '예시 코드 수정'},
    {'version': 'v1', 'date': '2026-05-18 20:00', 'desc': '최초 작성'},
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConceptPage(
      children: [
        const ConceptViewHead(title: '버전 이력'),
        Text(
          '노트 ID: ${widget.noteId}',
          style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._mockVersions.map(
          (v) => _VersionItem(
            version: v['version']!,
            date: v['date']!,
            description: v['desc']!,
            isSelected: _selectedVersion == v['version'],
            onTap: () => setState(() => _selectedVersion = v['version']),
          ),
        ),
        if (_selectedVersion != null) ...[
          ConceptSectionLabel('변경 사항 ($_selectedVersion)'),
          const _DiffView(),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _VersionItem extends StatelessWidget {
  const _VersionItem({
    required this.version,
    required this.date,
    required this.description,
    this.isSelected = false,
    this.onTap,
  });
  final String version;
  final String date;
  final String description;
  final bool isSelected;
  final VoidCallback? onTap;

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
                version,
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
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
              onPressed: () {
                // TODO: 팀원 구현 — 버전 복원 API 연동
              },
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

class _DiffView extends StatelessWidget {
  const _DiffView();

  static const _oldLines = [
    _DiffLine('### L1 정규화 (Lasso)', false),
    _DiffLine('- 가중치의 절댓값 합을 페널티로 추가', false),
    _DiffLine('- 특성 선택 효과가 있음', true),
    _DiffLine('', false),
    _DiffLine('### L2 정규화 (Ridge)', false),
    _DiffLine('- 가중치의 제곱합을 페널티로 추가', false),
  ];

  static const _newLines = [
    _DiffLine('### L1 정규화 (Lasso)', false),
    _DiffLine('- 가중치의 절댓값 합을 페널티로 추가', false),
    _DiffLine('- 일부 가중치를 0으로 만들어 희소성 유도', true),
    _DiffLine('', false),
    _DiffLine('### L2 정규화 (Ridge)', false),
    _DiffLine('- 가중치의 제곱합을 페널티로 추가', false),
    _DiffLine('- 가중치를 작게 유지하되 0으로 만들지 않음', true),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final monoStyle =
        textTheme.bodySmall?.copyWith(fontFamily: 'monospace') ??
        const TextStyle(fontFamily: 'monospace', fontSize: 12);

    // 비균일 색 Border + borderRadius 조합으로 인한 렌더 이슈를 피하기 위해
    // ClipRRect로 모서리를 클립하고 내부를 분리한다.
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Old (left)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      color: AppColors.surface2,
                      child: Text(
                        '이전',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    ..._oldLines.map(
                      (line) => Container(
                        width: double.infinity,
                        color: line.changed ? const Color(0x20DC2626) : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        child: Text(
                          line.changed ? '- ${line.text}' : '  ${line.text}',
                          style: monoStyle.copyWith(
                            color: line.changed ? AppColors.error : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: AppColors.border),
              // New (right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      color: AppColors.surface2,
                      child: Text(
                        '현재',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    ..._newLines.map(
                      (line) => Container(
                        width: double.infinity,
                        color: line.changed ? const Color(0x2016A34A) : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        child: Text(
                          line.changed ? '+ ${line.text}' : '  ${line.text}',
                          style: monoStyle.copyWith(
                            color: line.changed ? AppColors.success : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiffLine {
  const _DiffLine(this.text, this.changed);
  final String text;
  final bool changed;
}

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

  static const _presetColors = [
    Color(0xFFDC2626), // red
    Color(0xFFEA580C), // orange
    Color(0xFFD97706), // amber
    Color(0xFF16A34A), // green
    Color(0xFF2563EB), // blue
    Color(0xFF7C3AED), // violet
    Color(0xFFDB2777), // pink
    Color(0xFF78716C), // stone
  ];

  // TODO: 팀원 구현 — knowledge-svc 태그 목록 API 연동
  final _mockTags = [
    {'name': '머신러닝', 'count': 12},
    {'name': '알고리즘', 'count': 8},
    {'name': 'AWS', 'count': 5},
    {'name': '딥러닝', 'count': 7},
    {'name': '클라우드', 'count': 3},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTagMergeDialog(BuildContext context) {
    final tagNames = _mockTags.map((t) => t['name'].toString()).toList();
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
                // TODO: 팀원 구현 — 태그 병합 API 연동
                Navigator.of(ctx).pop();
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
    final filtered = _mockTags
        .where((t) => t['name'].toString().contains(_searchController.text))
        .toList();

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
                      const Icon(Icons.tag, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          tag['name'].toString(),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${tag['count']}개 노트',
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
                          // TODO: 팀원 구현 — 태그 삭제 API 연동
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
          ],
        ),
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: FloatingActionButton.extended(
            onPressed: () {
              // TODO: 팀원 구현 — 태그 추가 다이얼로그
            },
            icon: const Icon(Icons.add),
            label: const Text('태그 추가'),
          ),
        ),
      ],
    );
  }
}
