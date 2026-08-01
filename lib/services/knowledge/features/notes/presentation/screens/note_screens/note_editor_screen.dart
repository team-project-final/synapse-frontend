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
  final _titleController = TextEditingController();
  final _controller = TextEditingController();
  late final TabController _tabController;
  String _markdown = '';
  KnowledgeNote? _loadedNote;
  Timer? _autosaveTimer;
  bool _isSaving = false;
  bool _isAutosaving = false;
  bool _suppressChanges = false;
  String? _saveError;
  DateTime? _lastSavedAt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _titleController.addListener(_onEditorChanged);
    _controller.addListener(_onEditorChanged);
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
    _autosaveTimer?.cancel();
    _titleController.dispose();
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onEditorChanged() {
    if (_suppressChanges) return;
    setState(() {
      _markdown = _controller.text;
      _saveError = null;
    });

    if (widget.noteId == 'new') return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(
      const Duration(seconds: 2),
      () => unawaited(_saveNote(autosave: true)),
    );
  }

  void _scheduleHydrate(KnowledgeNote note) {
    if (_loadedNote?.id == note.id) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadedNote?.id == note.id) return;
      _suppressChanges = true;
      _titleController.text = note.title;
      _controller.text = note.contentMd;
      _suppressChanges = false;
      setState(() {
        _loadedNote = note;
        _markdown = note.contentMd;
        _lastSavedAt = note.updatedAt;
      });
    });
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
    if (widget.noteId != 'new') {
      final noteValue = ref.watch(noteDetailProvider(widget.noteId));
      return AppAsyncValueWidget<KnowledgeNote>(
        value: noteValue,
        loading: const AppLoadingWidget(label: '편집할 노트를 불러오는 중입니다.'),
        error: (error, _) => AppErrorWidget(
          message: '편집할 노트를 불러오지 못했습니다.',
          onRetry: () => ref.invalidate(noteDetailProvider(widget.noteId)),
        ),
        data: (note) {
          _scheduleHydrate(note);
          return _buildEditorScaffold(context);
        },
      );
    }
    return _buildEditorScaffold(context);
  }

  Widget _buildEditorScaffold(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final statusLabel = _isSaving
        ? '저장 중'
        : _isAutosaving
        ? '자동저장 중'
        : _lastSavedAt == null
        ? '저장 대기'
        : '저장됨';
    final statusColor = _saveError != null
        ? AppColors.error
        : AppColors.success;

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
              Icon(Icons.circle, size: 8, color: statusColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                statusLabel,
                style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton(
                onPressed: _isSaving ? null : () => unawaited(_saveNote()),
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
          child: Column(
            children: [
              if (_saveError != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  color: AppColors.error.withValues(alpha: 0.08),
                  child: Text(
                    _saveError!,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Expanded(
                child: isMobile
                    ? _buildMobileTabView(textTheme)
                    : _buildDesktopSplitView(textTheme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 편집 영역 = 마크다운 입력 + `[[` 자동완성 드롭다운 + AI 정리 제안 카드.
  /// v1 목업 ④의 핵심 디테일을 데스크탑/모바일 양쪽에서 재사용한다.
  Widget _buildEditorPane(TextTheme textTheme, {required bool expandField}) {
    final query = _wikiQuery;
    final autocompleteValue = query == null
        ? null
        : ref.watch(
            knowledgeSearchProvider(
              KnowledgeSearchQuery(query: query, semantic: false, limit: 5),
            ),
          );
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
    );

    final extras = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (query != null && autocompleteValue != null)
          autocompleteValue.when(
            data: (page) => _WikiAutocomplete(
              query: query,
              candidates: [
                for (final result in page.results)
                  (result.title, '연관도 ${result.score.toStringAsFixed(2)}'),
              ],
              onSelect: _acceptWiki,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: LinearProgressIndicator(),
            ),
            error: (_, _) => const SizedBox.shrink(),
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
            const SizedBox(height: AppSpacing.md),
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _buildTitlePane(textTheme),
                const Divider(height: AppSpacing.lg),
                Expanded(child: _buildEditorPane(textTheme, expandField: true)),
              ],
            ),
          ),
        ),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: _buildTitlePane(textTheme),
        ),
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

  Widget _buildTitlePane(TextTheme textTheme) {
    return TextField(
      controller: _titleController,
      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      decoration: const InputDecoration(
        hintText: '노트 제목',
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }

  Future<void> _saveNote({bool autosave = false}) async {
    final title = _titleController.text.trim();
    final content = _controller.text.trim();
    if (title.isEmpty || content.isEmpty) {
      if (!autosave) {
        setState(() => _saveError = '제목과 본문을 입력하세요.');
      }
      return;
    }

    setState(() {
      if (autosave) {
        _isAutosaving = true;
      } else {
        _isSaving = true;
      }
      _saveError = null;
    });

    try {
      final tenant = await ref.read(currentTenantProvider.future);
      final api = ref.read(knowledgeApiProvider);
      final saved = widget.noteId == 'new'
          ? await api.createNote(
              tenantId: tenant.id,
              title: title,
              contentMd: content,
              tags: _extractTags(content),
            )
          : await api.updateNote(
              noteId: widget.noteId,
              tenantId: tenant.id,
              title: title,
              contentMd: content,
              tags: _extractTags(content),
              deckId: _loadedNote?.deckId,
            );
      ref.invalidate(noteListProvider);
      ref.invalidate(popularTagsProvider);
      ref.invalidate(knowledgeGraphProvider);
      ref.invalidate(noteDetailProvider(saved.id));
      if (widget.noteId != 'new') {
        ref.invalidate(noteDetailProvider(widget.noteId));
      }
      if (!mounted) return;
      setState(() {
        _loadedNote = saved;
        _lastSavedAt = saved.updatedAt ?? DateTime.now();
      });
      if (!autosave) {
        context.go(AppRoutes.noteDetailPath(saved.id));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saveError = autosave ? '자동저장에 실패했습니다. 다시 시도해 주세요.' : '노트를 저장하지 못했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          if (autosave) {
            _isAutosaving = false;
          } else {
            _isSaving = false;
          }
        });
      }
    }
  }

  List<String> _extractTags(String content) {
    final matches = RegExp(r'(^|\s)#([^\s#]{1,30})').allMatches(content);
    return matches
        .map((match) => match.group(2) ?? '')
        .where((tag) => tag.isNotEmpty)
        .take(10)
        .toSet()
        .toList(growable: false);
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
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: InkWell(
                onTap: () => onSelect(filtered[i].$1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
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
