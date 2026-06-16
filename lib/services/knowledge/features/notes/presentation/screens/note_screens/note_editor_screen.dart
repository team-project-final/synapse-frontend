part of '../note_screens.dart';

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
  final _titleController = TextEditingController();
  late final TabController _tabController;
  String _markdown = '';

  /// 수정 시 원본 태그 보존용 (태그 편집 UI는 5단계 — 지금은 로드한 태그를 그대로 재전송).
  List<String> _tags = const <String>[];

  bool _loadingNote = false; // 수정 진입 시 기존 노트 로딩
  bool _saving = false;
  String? _loadError;

  bool get _isNew => widget.noteId == 'new';

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
    // 제목 변경 시에도 미리보기가 갱신되도록.
    _titleController.addListener(() => setState(() {}));
    if (!_isNew) {
      _loadExistingNote();
    }
  }

  /// 수정 진입 시 기존 노트(제목·본문·태그)를 불러와 입력칸을 채운다.
  Future<void> _loadExistingNote() async {
    setState(() => _loadingNote = true);
    try {
      final Note note = await ref.read(getNoteUseCaseProvider).call(widget.noteId);
      _titleController.text = note.title;
      _controller.text = note.contentMd;
      setState(() {
        _tags = note.tags;
        _markdown = note.contentMd;
        _loadingNote = false;
      });
    } catch (_) {
      setState(() {
        _loadError = '노트를 불러오지 못했어요';
        _loadingNote = false;
      });
    }
  }

  /// 저장 — 신규는 POST, 기존은 PATCH. 성공 시 상세로 이동, 실패 시 SnackBar.
  Future<void> _save() async {
    final String title = _titleController.text.trim();
    final String content = _controller.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력하세요')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final Note saved = _isNew
          ? await ref.read(createNoteUseCaseProvider).call(
              title: title, contentMd: _controller.text, tags: _tags)
          : await ref.read(updateNoteUseCaseProvider).call(
              noteId: widget.noteId,
              title: title,
              contentMd: _controller.text,
              tags: _tags);

      ref.invalidate(notesListProvider);
      ref.invalidate(noteDetailProvider(saved.id));
      if (!mounted) return;
      context.go(AppRoutes.noteDetailPath(saved.id));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했어요. 다시 시도해주세요.')),
      );
    }
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
    _titleController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// 선택한 텍스트를 prefix/suffix 로 감싼다.
  /// - 선택이 있으면: `prefix + 선택텍스트 + suffix` (예: "안녕" → "**안녕**")
  /// - 선택이 없으면: placeholder 를 끼워 넣고 그 placeholder 를 선택 상태로 둔다(바로 덮어쓰게).
  void _wrapSelection(String prefix, String suffix, {String placeholder = ''}) {
    final String text = _controller.text;
    final TextSelection sel = _controller.selection;
    final int start = sel.start < 0 ? text.length : sel.start;
    final int end = sel.end < 0 ? text.length : sel.end;
    final bool hasSelection = start != end;
    final String inner = hasSelection ? text.substring(start, end) : placeholder;

    final String newText = text.replaceRange(start, end, '$prefix$inner$suffix');
    final int innerStart = start + prefix.length;
    final int innerEnd = innerStart + inner.length;

    _controller.value = TextEditingValue(
      text: newText,
      // 선택 없이 placeholder 를 넣었으면 그 placeholder 를 선택해 바로 교체 가능하게,
      // 선택이 있었으면 닫는 기호 뒤로 커서를 둔다.
      selection: (!hasSelection && placeholder.isNotEmpty)
          ? TextSelection(baseOffset: innerStart, extentOffset: innerEnd)
          : TextSelection.collapsed(offset: innerEnd + suffix.length),
    );
  }

  /// 헤딩 등 줄 단위 마크다운 — 현재 커서가 있는 줄의 **맨 앞**에 prefix(`# `)를 넣는다.
  /// (마크다운 헤딩은 줄 시작에 와야 렌더되므로 커서 위치가 아니라 줄 시작에 삽입)
  void _insertLinePrefix(String prefix) {
    final String text = _controller.text;
    final TextSelection sel = _controller.selection;
    final int caret = sel.isValid ? sel.baseOffset.clamp(0, text.length) : text.length;
    final int lineStart = text.lastIndexOf('\n', caret - 1) + 1;

    final String newText = text.replaceRange(lineStart, lineStart, prefix);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: caret + prefix.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    // 수정 진입 시 기존 노트 로딩 / 실패 상태 처리
    if (_loadingNote) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(_loadError!, style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.notes),
              child: const Text('라이브러리'),
            ),
          ],
        ),
      );
    }

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
                        onTap: () => _wrapSelection('**', '**', placeholder: '텍스트'),
                      ),
                      _ToolbarButton(
                        icon: Icons.format_italic,
                        tooltip: 'Italic',
                        onTap: () => _wrapSelection('*', '*', placeholder: '텍스트'),
                      ),
                      _ToolbarButton(
                        icon: Icons.title,
                        tooltip: 'Heading 1',
                        onTap: () => _insertLinePrefix('# '),
                      ),
                      _ToolbarButton(
                        icon: Icons.text_fields,
                        tooltip: 'Heading 2',
                        onTap: () => _insertLinePrefix('## '),
                      ),
                      _ToolbarButton(
                        icon: Icons.link,
                        tooltip: 'Link',
                        // 선택이 있으면 [[선택]] 으로 감싸고, 없으면 [[ 만 열어 자동완성을 띄운다.
                        onTap: () {
                          final TextSelection s = _controller.selection;
                          if (s.isValid && s.start != s.end) {
                            _wrapSelection('[[', ']]');
                          } else {
                            _wrapSelection('[[', '');
                          }
                        },
                      ),
                      _ToolbarButton(
                        icon: Icons.code,
                        tooltip: 'Code',
                        onTap: () => _wrapSelection('`', '`', placeholder: '코드'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isNew ? '등록' : '저장'),
              ),
            ],
          ),
        ),
        // 제목 입력 (백엔드 title 필수)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: TextField(
            controller: _titleController,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            decoration: const InputDecoration(
              hintText: '제목을 입력하세요',
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
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
            child: _buildPreview(textTheme),
          ),
        ),
      ],
    );
  }

  /// 미리보기 — 제목 + 본문(마크다운). 둘 다 비면 안내 문구.
  Widget _buildPreview(TextTheme textTheme) {
    final String title = _titleController.text.trim();
    if (title.isEmpty && _markdown.trim().isEmpty) {
      return Center(
        child: Text(
          '미리보기가 여기에 표시됩니다',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          MarkdownBody(data: _markdown),
        ],
      ),
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
                child: _buildPreview(textTheme),
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
