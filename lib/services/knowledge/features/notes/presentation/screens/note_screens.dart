import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class NoteListScreen extends ConsumerWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '노트 목록',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-001',
      routeHint: '/notes',
    );
  }
}

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '노트 상세 보기',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-003',
      routeHint: '/notes/$noteId',
    );
  }
}

// ── Note Editor (split view) ──

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
      selection:
          TextSelection.collapsed(offset: start + syntax.length),
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
          decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: AppColors.stone200)),
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
              style:
                  textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: '마크다운으로 작성하세요...',
                border: InputBorder.none,
              ),
              // TODO: 팀원 구현 — knowledge-svc API 연동, 위키링크 파싱
            ),
          ),
        ),
        VerticalDivider(width: 1, color: AppColors.stone200),
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
                  style: textTheme.bodyLarge
                      ?.copyWith(fontFamily: 'monospace'),
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

// ── Remaining screens (placeholders) ──

class NoteVersionsScreen extends ConsumerWidget {
  const NoteVersionsScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DomainPlaceholderScaffold(
      title: '버전 이력',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-004',
      routeHint: '/notes/$noteId/versions',
    );
  }
}

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '태그 관리',
      domain: 'NOTE',
      screenId: 'SCR-W-NOTE-005',
      routeHint: '/tags',
    );
  }
}
