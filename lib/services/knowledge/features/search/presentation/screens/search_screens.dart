import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/learning/features/ai/providers/ai_providers.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_item.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_mode.dart';
import 'package:synapse_frontend/services/knowledge/features/search/domain/entities/knowledge_search_result.dart';
import 'package:synapse_frontend/services/knowledge/features/search/providers/search_providers.dart';
import 'package:synapse_frontend/shared/widgets/ai_thinking_loader.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

// ── SearchScreen (SCR-W-SEARCH-001) ──

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TextSpan> _highlightText(
    String text,
    String query,
    TextStyle? baseStyle,
  ) {
    if (query.isEmpty) return [TextSpan(text: text, style: baseStyle)];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: baseStyle?.copyWith(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = index + query.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final searchState = ref.watch(knowledgeSearchNotifierProvider);
    final searchNotifier = ref.read(knowledgeSearchNotifierProvider.notifier);
    final resultState = searchState.result;
    final query = searchState.query;
    final isSemanticMode = searchState.mode == KnowledgeSearchMode.semantic;

    return ConceptPage(
      children: [
        // 입력형 검색 바
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.muted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '노트, 카드, 태그 검색…',
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  onChanged: searchNotifier.updateQuery,
                  onSubmitted: (_) => searchNotifier.submitSearch(),
                ),
              ),
              if (searchState.hasQuery)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  color: AppColors.muted,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _searchController.clear();
                    searchNotifier.clear();
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // 의미 검색 / 키워드 토글
        Row(
          children: [
            ConceptFilterPill(
              label: '✦ 의미 검색',
              selected: isSemanticMode,
              onTap: () => searchNotifier.setMode(KnowledgeSearchMode.semantic),
            ),
            const SizedBox(width: AppSpacing.sm),
            ConceptFilterPill(
              label: '키워드',
              selected: !isSemanticMode,
              onTap: () => searchNotifier.setMode(KnowledgeSearchMode.keyword),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isSemanticMode
              ? '키워드를 넘어 의미로 — pgvector + Elasticsearch 하이브리드'
              : '제목·본문 키워드 일치 검색',
          style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
        ),
        if (isSemanticMode &&
            resultState.asData?.value.semanticFallback == true) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            '의미 검색을 사용할 수 없어 키워드 결과로 대체되었습니다.',
            style: textTheme.labelMedium?.copyWith(color: AppColors.warning),
          ),
        ],
        if (!searchState.hasQuery)
          const ConceptEmptyState(
            emoji: '🔍',
            title: '검색어를 입력하세요',
            body: '노트, 카드, 태그를 한번에 검색할 수 있습니다',
          )
        else
          resultState.when(
            data: (KnowledgeSearchResult result) {
              if (result.items.isEmpty) {
                return const ConceptEmptyState(
                  emoji: '🗂️',
                  title: '검색 결과가 없습니다',
                  body: '다른 검색어로 다시 시도해보세요',
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ConceptSectionLabel('관련 결과'),
                  for (final KnowledgeSearchItem result in result.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ConceptCard(
                        onTap: () => context.go(
                          AppRoutes.noteDetailPath(result.noteId),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: _highlightText(
                                  result.title,
                                  query,
                                  textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            if (result.snippet.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              RichText(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: _highlightText(
                                    result.snippet,
                                    query,
                                    textTheme.bodySmall?.copyWith(
                                      color: AppColors.muted,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, __) => const ConceptEmptyState(
              emoji: '⚠️',
              title: '검색 결과를 불러오지 못했습니다',
              body: '잠시 후 다시 시도해주세요',
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// AI 답변 인용 소스 칩 (목업 `.src`).
class _SourceChip extends StatelessWidget {
  const _SourceChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '📄 $label',
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── AiQaScreen (SCR-W-SEARCH-002) ──

class AiQaScreen extends ConsumerStatefulWidget {
  const AiQaScreen({super.key});

  @override
  ConsumerState<AiQaScreen> createState() => _AiQaScreenState();
}

class _AiQaScreenState extends ConsumerState<AiQaScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final qaState = ref.watch(qaNotifierProvider);

    ref.listen(qaNotifierProvider, (_, __) => _scrollToBottom());

    // QaMessage → _ChatMessage 변환 (기존 _ChatBubble 재사용)
    final messages = qaState.messages
        .map((m) => _ChatMessage(
              isUser: m.isUser,
              text: m.text,
              time: '',
              sources: const [],
            ))
        .toList();

    return Column(
      children: [
        // 대화 헤더
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const SynapseOrb(size: 32, glyphScale: 0.47),
              const SizedBox(width: AppSpacing.sm + 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 튜터',
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    qaState.isStreaming ? '● 답변 중' : '● 대기 중',
                    style: textTheme.labelSmall?.copyWith(
                      color: qaState.isStreaming
                          ? AppColors.success
                          : AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 메시지 목록
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        '노트 내용에 대해 무엇이든 질문해보세요',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        // 첫 토큰 전(빈 AI 버블) 동안 챗봇 로띠 로더 표시.
                        final isPendingAi = i == messages.length - 1 &&
                            !messages[i].isUser &&
                            messages[i].text.isEmpty &&
                            qaState.isStreaming;
                        if (isPendingAi) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AiThinkingLoader(message: '답변 준비 중…'),
                          );
                        }
                        return _ChatBubble(message: messages[i]);
                      },
                    ),
            ),
          ),
        ),

        // 스트리밍 인디케이터 — 답변이 흐르기 시작한 뒤에만(초기엔 로띠 로더가 대신).
        if (qaState.isStreaming &&
            qaState.messages.isNotEmpty &&
            qaState.messages.last.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '생성 중…',
                  style:
                      textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),

        // 입력창
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  enabled: !qaState.isStreaming,
                  decoration: InputDecoration(
                    hintText: '노트 내용에 대해 질문하세요…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    filled: true,
                    fillColor: AppColors.surface2,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: qaState.isStreaming ? null : _sendMessage,
                icon: const Icon(Icons.arrow_upward),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryFg,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(qaNotifierProvider.notifier).sendMessage(text);
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.sources = const [],
  });
  final bool isUser;
  final String text;
  final String time;
  final List<String> sources;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(
            bottom: AppSpacing.sm,
            left: AppSpacing.xxl,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(AppRadius.lg),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryFg,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                message.time,
                style: textTheme.labelSmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: AppSpacing.sm,
          right: AppSpacing.xxl,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(AppRadius.lg),
            bottomRight: Radius.circular(AppRadius.lg),
          ),
          border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SynapseOrb(size: 22, glyphScale: 0.5),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  'Synapse AI',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _AnimatedTypingText(
              text: message.text,
              style: textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
            if (message.sources.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm + 2),
              Wrap(
                spacing: AppSpacing.xs + 2,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '인용 소스',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  for (final src in message.sources) _SourceChip(src),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            // Feedback buttons + time
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  onPressed: () {
                    // TODO: 팀원 구현 — 피드백 API 연동
                  },
                  visualDensity: VisualDensity.compact,
                  color: AppColors.muted,
                  tooltip: '좋아요',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(AppSpacing.xs),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: const Icon(Icons.thumb_down_outlined, size: 16),
                  onPressed: () {
                    // TODO: 팀원 구현 — 피드백 API 연동
                  },
                  visualDensity: VisualDensity.compact,
                  color: AppColors.muted,
                  tooltip: '싫어요',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(AppSpacing.xs),
                ),
                const Spacer(),
                Text(
                  message.time,
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

class _AnimatedTypingText extends StatefulWidget {
  const _AnimatedTypingText({required this.text, this.style});
  final String text;
  final TextStyle? style;

  @override
  State<_AnimatedTypingText> createState() => _AnimatedTypingTextState();
}

class _AnimatedTypingTextState extends State<_AnimatedTypingText> {
  int _charCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(_AnimatedTypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text == widget.text) return;
    _timer?.cancel();
    // 스트리밍: 기존 텍스트의 연장이면 현재 위치에서 계속 진행
    if (!widget.text.startsWith(oldWidget.text)) _charCount = 0;
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_charCount >= widget.text.length) {
        timer.cancel();
        return;
      }
      if (mounted) setState(() => _charCount++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.text.substring(0, _charCount), style: widget.style);
  }
}
