import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── Mock data ──

class _MockNote {
  const _MockNote({
    required this.id,
    required this.title,
    required this.snippet,
    required this.tags,
    required this.timeAgo,
  });
  final String id;
  final String title;
  final String snippet;
  final List<String> tags;
  final String timeAgo;
}

const _mockNotes = [
  _MockNote(
    id: '1',
    title: '정규화 기법 (Regularization)',
    snippet: 'L1/L2 정규화는 과적합을 방지하기 위한 기법입니다. L1은 Lasso, L2는 Ridge라고 불립니다.',
    tags: ['머신러닝', '딥러닝'],
    timeAgo: '2시간 전',
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
  final _searchController = TextEditingController();
  String _selectedFilter = '전체';
  String _sortOrder = '최근 수정';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filters = ['전체', '최근', '즐겨찾기'];

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '노트 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                filled: true,
                fillColor: AppColors.stone50,
              ),
              onChanged: (_) => setState(() {}),
              // TODO: 팀원 구현 — knowledge-svc 검색 API 연동
            ),
            const SizedBox(height: AppSpacing.sm),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((f) {
                  final selected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(f),
                      selected: selected,
                      selectedColor: colorScheme.primaryContainer,
                      onSelected: (_) => setState(() => _selectedFilter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Sort order dropdown
            Row(
              children: [
                Text('정렬:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.stone500)),
                const SizedBox(width: AppSpacing.xs),
                DropdownButton<String>(
                  value: _sortOrder,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.stone600),
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
            const SizedBox(height: AppSpacing.md),
            // Note list
            // TODO: 팀원 구현 — knowledge-svc 노트 목록 API 연동
            ..._mockNotes.map((note) => _NoteCard(note: note)),
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
          ],
        ),
        // FAB
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: FloatingActionButton.extended(
            onPressed: () => context.go(AppRoutes.noteEditorPath('new')),
            icon: const Icon(Icons.add),
            label: const Text('새 노트'),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.go(AppRoutes.noteDetailPath(note.id)),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(note.title, style: textTheme.bodyLarge),
                  ),
                  Text(note.timeAgo,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone400)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: note.tags
                    .map((tag) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: Chip(
                            label: Text(tag,
                                style: textTheme.bodySmall
                                    ?.copyWith(fontSize: 11)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                note.snippet,
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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

    // TODO: 팀원 구현 — knowledge-svc 노트 상세 API 연동 (noteId: $noteId)
    const mockContent = '''
## 정규화 기법 (Regularization)

정규화는 머신러닝 모델의 **과적합(Overfitting)**을 방지하는 핵심 기법입니다.

### L1 정규화 (Lasso)
- 가중치의 절댓값 합을 페널티로 추가
- 일부 가중치를 정확히 0으로 만들어 **희소성(Sparsity)** 유도
- 특성 선택 효과가 있음

### L2 정규화 (Ridge)
- 가중치의 제곱합을 페널티로 추가
- 가중치를 작게 만들되 0에 가깝게만 유지

참고: [[드롭아웃]], [[배치 정규화]]
''';

    final mainContent = SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + tags
          Text('정규화 기법 (Regularization)',
              style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: ['머신러닝', '딥러닝']
                .map((t) => Chip(
                      label: Text(t, style: textTheme.bodySmall),
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          // TODO: 팀원 구현 — 노트 태그 동적 연동
          const SizedBox(height: AppSpacing.md),
          // Markdown body
          const MarkdownBody(data: mockContent),
          const SizedBox(height: AppSpacing.xs),
          // WikiLink chips
          Row(
            children: [
              const Icon(Icons.link, size: 14, color: AppColors.stone400),
              const SizedBox(width: AppSpacing.xs),
              ActionChip(
                label: const Text('드롭아웃'),
                onPressed: () => context.go(AppRoutes.noteDetailPath('2')),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: AppSpacing.xs),
              ActionChip(
                label: const Text('배치 정규화'),
                onPressed: () => context.go(AppRoutes.noteDetailPath('3')),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Action row
          Row(
            children: [
              FilledButton.icon(
                onPressed: () =>
                    context.go(AppRoutes.noteEditorPath(noteId)),
                icon: const Icon(Icons.edit),
                label: const Text('편집'),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go(AppRoutes.noteVersionsPath(noteId)),
                icon: const Icon(Icons.history),
                label: const Text('버전 이력'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Backlinks
          Text('이 노트를 참조하는 노트 (2)',
              style: textTheme.titleMedium
                  ?.copyWith(color: AppColors.stone600)),
          const Divider(height: AppSpacing.md),
          // TODO: 팀원 구현 — knowledge-svc 백링크 API 연동
          _BacklinkItem(
            title: '드롭아웃 기법',
            snippet: '...과적합 방지를 위한 또 다른 기법으로 [[정규화 기법]]을 함께 사용합니다...',
            onTap: () => context.go(AppRoutes.noteDetailPath('2')),
          ),
          _BacklinkItem(
            title: 'Ridge vs Lasso 비교',
            snippet: '...L2 정규화([[정규화 기법]])는 Ridge 회귀에 해당합니다...',
            onTap: () => context.go(AppRoutes.noteDetailPath('3')),
          ),
          const SizedBox(height: AppSpacing.lg),
          // 참조 노트 section
          Text('참조 노트 (2)',
              style: textTheme.titleMedium
                  ?.copyWith(color: AppColors.stone600)),
          const Divider(height: AppSpacing.md),
          _BacklinkItem(
            title: '드롭아웃 (Dropout)',
            snippet: '과적합 방지를 위해 학습 시 뉴런을 랜덤하게 비활성화하는 기법입니다.',
            onTap: () => context.go(AppRoutes.noteDetailPath('4')),
          ),
          _BacklinkItem(
            title: '배치 정규화 (Batch Normalization)',
            snippet: '미니배치 단위로 입력을 정규화하여 학습 속도를 향상시키는 기법입니다.',
            onTap: () => context.go(AppRoutes.noteDetailPath('5')),
          ),
        ],
      ),
    );

    final backlinkPanel = isMobile
        ? const SizedBox.shrink()
        : Container(
            width: 280,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.stone200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('백링크',
                      style: textTheme.titleSmall
                          ?.copyWith(color: AppColors.stone600)),
                ),
                const Divider(height: 1),
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

    if (isMobile) {
      return mainContent;
    }
    return Row(
      children: [
        Expanded(child: mainContent),
        backlinkPanel,
      ],
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
    return ListTile(
      leading:
          const Icon(Icons.arrow_back, size: 16, color: AppColors.stone400),
      title: Text(title, style: textTheme.bodyMedium),
      subtitle: Text(snippet,
          style: textTheme.bodySmall?.copyWith(color: AppColors.stone500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis),
      onTap: onTap,
      dense: true,
    );
  }
}

// ── NoteEditorScreen (split view) — DO NOT CHANGE ──

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      setState(() => _markdown = _controller.text);
    });
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
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.stone200)),
          ),
          child: Row(
            children: [
              _ToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: 'Bold',
                  onTap: () => _insertMarkdown('**텍스트**')),
              _ToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: 'Italic',
                  onTap: () => _insertMarkdown('*텍스트*')),
              _ToolbarButton(
                  icon: Icons.title,
                  tooltip: 'Heading 1',
                  onTap: () => _insertMarkdown('# ')),
              _ToolbarButton(
                  icon: Icons.text_fields,
                  tooltip: 'Heading 2',
                  onTap: () => _insertMarkdown('## ')),
              _ToolbarButton(
                  icon: Icons.link,
                  tooltip: 'Link',
                  onTap: () => _insertMarkdown('[텍스트](url)')),
              _ToolbarButton(
                  icon: Icons.code,
                  tooltip: 'Code',
                  onTap: () => _insertMarkdown('`코드`')),
              const Spacer(),
              // 자동저장 인디케이터
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('저장됨',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone400)),
                  // TODO: 팀원 구현 — 자동저장 상태 연동
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              // 등록/저장 버튼
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
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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

  Widget _buildDesktopSplitView(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: '마크다운으로 작성하세요...',
                border: InputBorder.none,
              ),
              // TODO: 팀원 구현 — knowledge-svc API 연동, 위키링크 파싱
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: AppColors.stone200),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _markdown.isEmpty
                ? Center(
                    child: Text('미리보기가 여기에 표시됩니다',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.stone400)))
                : SingleChildScrollView(
                    child: MarkdownBody(data: _markdown),
                  ),
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
          tabs: const [Tab(text: '편집'), Tab(text: '미리보기')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style:
                      textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    hintText: '마크다운으로 작성하세요...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _markdown.isEmpty
                    ? Center(
                        child: Text('미리보기가 여기에 표시됩니다',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: AppColors.stone400)))
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
      visualDensity: VisualDensity.compact,
    );
  }
}

// ── NoteVersionsScreen (SCR-W-NOTE-004) ──

class NoteVersionsScreen extends ConsumerStatefulWidget {
  const NoteVersionsScreen({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<NoteVersionsScreen> createState() =>
      _NoteVersionsScreenState();
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

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('버전 이력', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text('노트 ID: ${widget.noteId}',
            style: textTheme.bodySmall?.copyWith(color: AppColors.stone400)),
        const SizedBox(height: AppSpacing.md),
        ..._mockVersions.map((v) => _VersionItem(
              version: v['version']!,
              date: v['date']!,
              description: v['desc']!,
              isSelected: _selectedVersion == v['version'],
              onTap: () =>
                  setState(() => _selectedVersion = v['version']),
            )),
        if (_selectedVersion != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text('변경 사항 ($_selectedVersion)',
              style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          const _DiffView(),
        ],
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: isSelected ? AppColors.stone100 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryAmber.withValues(alpha: 0.15) : AppColors.stone100,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Text(version,
                    style: textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(description, style: textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(date,
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.stone400)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  // TODO: 팀원 구현 — 버전 복원 API 연동
                },
                child: const Text('복원'),
              ),
            ],
          ),
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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.stone200),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Old (left)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  color: AppColors.stone100,
                  child: Text('이전', style: textTheme.labelSmall?.copyWith(color: AppColors.stone500)),
                ),
                ..._oldLines.map((line) => Container(
                      width: double.infinity,
                      color: line.changed
                          ? const Color(0x20DC2626)
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                      child: RichText(
                        text: TextSpan(
                          text: line.changed ? '- ${line.text}' : '  ${line.text}',
                          style: monoStyle.copyWith(
                            color: line.changed ? AppColors.error : null,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          Container(width: 1, color: AppColors.stone200),
          // New (right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  color: AppColors.stone100,
                  child: Text('현재', style: textTheme.labelSmall?.copyWith(color: AppColors.stone500)),
                ),
                ..._newLines.map((line) => Container(
                      width: double.infinity,
                      color: line.changed
                          ? const Color(0x2016A34A)
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                      child: RichText(
                        text: TextSpan(
                          text: line.changed ? '+ ${line.text}' : '  ${line.text}',
                          style: monoStyle.copyWith(
                            color: line.changed ? AppColors.success : null,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
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
  int _selectedColorIndex = 0;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '태그 검색...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                filled: true,
                fillColor: AppColors.stone50,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            // Color picker
            Text('태그 색상', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(_presetColors.length, (i) {
                final isSelected = _selectedColorIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = i),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _presetColors[i],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.stone800, width: 2.5)
                          : Border.all(color: AppColors.stone200),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            // Tag merge button
            OutlinedButton.icon(
              onPressed: () => _showTagMergeDialog(context),
              icon: const Icon(Icons.merge_type),
              label: const Text('태그 병합'),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._mockTags
                .where((t) => t['name']
                    .toString()
                    .contains(_searchController.text))
                .map((tag) => ListTile(
                      leading: const Icon(Icons.tag, color: AppColors.stone400),
                      title: Text(tag['name'].toString(),
                          style: textTheme.bodyLarge),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: AppColors.stone100,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.xl),
                            ),
                            child: Text('${tag['count']}개 노트',
                                style: textTheme.bodySmall
                                    ?.copyWith(color: AppColors.stone500)),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            onPressed: () {
                              // TODO: 팀원 구현 — 태그 삭제 API 연동
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    )),
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
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
