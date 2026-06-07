import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ── SearchScreen (SCR-W-SEARCH-001) ──

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _hasQuery = false;
  late final TabController _tabController;

  static const _categoryTabs = ['전체', '노트', '카드', '커뮤니티'];
  static const _categoryCounts = [3, 2, 1, 0];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryTabs.length, vsync: this);
  }

  // TODO: 팀원 구현 — knowledge-svc / learning-svc 통합 검색 API 연동
  final _mockResults = [
    {
      'title': '정규화 기법 (Regularization)',
      'snippet': 'L1/L2 정규화는 과적합을 방지하기 위한 기법입니다.',
      'tags': ['머신러닝', '딥러닝'],
      'time': '2시간 전',
      'id': '1',
    },
    {
      'title': '동적 프로그래밍 기초',
      'snippet': '메모이제이션과 타뷸레이션을 사용하여 중복 계산을 피합니다.',
      'tags': ['알고리즘'],
      'time': '어제',
      'id': '2',
    },
    {
      'title': 'Ridge vs Lasso 비교',
      'snippet': 'L2 정규화(Ridge)와 L1 정규화(Lasso)의 차이를 분석합니다.',
      'tags': ['머신러닝', '정규화'],
      'time': '3일 전',
      'id': '3',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<TextSpan> _highlightText(String text, String query, TextStyle? baseStyle) {
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
        spans.add(TextSpan(text: text.substring(start, index), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: baseStyle?.copyWith(
          backgroundColor: AppColors.primaryAmber.withValues(alpha: 0.25),
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + query.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: '노트, 카드, 태그 검색...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _hasQuery = false);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              filled: true,
              fillColor: AppColors.stone50,
            ),
            onChanged: (v) => setState(() => _hasQuery = v.isNotEmpty),
          ),
        ),
        // Category tabs with badges
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: List.generate(_categoryTabs.length, (i) {
            final count = _categoryCounts[i];
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_categoryTabs[i]),
                  if (_hasQuery && count > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Badge(
                      label: Text('$count'),
                      backgroundColor: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Results or empty state
        Expanded(
          child: _hasQuery
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  itemCount: _mockResults.length,
                  itemBuilder: (context, i) {
                    final result = _mockResults[i];
                    final tags = result['tags'] as List<String>;
                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: InkWell(
                        onTap: () => context.go(
                            AppRoutes.noteDetailPath(
                                result['id'] as String)),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.sm),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: _highlightText(
                                          result['title'] as String,
                                          _searchController.text,
                                          textTheme.titleSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(result['time'] as String,
                                      style: textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppColors.stone400)),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              RichText(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: _highlightText(
                                    result['snippet'] as String,
                                    _searchController.text,
                                    textTheme.bodySmall?.copyWith(
                                        color: AppColors.stone500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                children: tags
                                    .map((tag) => Chip(
                                          label: Text(tag,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                      fontSize: 11)),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                          visualDensity:
                                              VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search,
                          size: 80, color: AppColors.stone300),
                      const SizedBox(height: AppSpacing.md),
                      Text('검색어를 입력하세요',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: AppColors.stone400)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '노트, 카드, 태그를 한번에 검색할 수 있습니다',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.stone300),
                      ),
                    ],
                  ),
                ),
        ),
      ],
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

  // TODO: 팀원 구현 — RAG Q&A API 연동 (스트리밍)
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      isUser: true,
      text: '정규화 기법에 대해 설명해줘',
      time: '14:30',
    ),
    const _ChatMessage(
      isUser: false,
      text: 'L1/L2 정규화는 과적합(Overfitting)을 방지하기 위한 기법입니다.\n\n'
          '**L1 정규화 (Lasso)**\n'
          '- 가중치의 절댓값 합을 페널티로 추가합니다\n'
          '- 일부 가중치를 0으로 만들어 희소성을 유도합니다\n\n'
          '**L2 정규화 (Ridge)**\n'
          '- 가중치의 제곱합을 페널티로 추가합니다\n'
          '- 가중치를 작게 유지하되 완전히 0으로 만들지 않습니다\n\n'
          '관련 노트: [[정규화 기법]], [[과적합 방지]]',
      time: '14:30',
      sources: ['정규화 기법', '과적합 방지'],
    ),
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final msg = _messages[i];
              return _ChatBubble(message: msg);
            },
          ),
        ),
        // Streaming indicator placeholder
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '생성 중...',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone400),
              ),
              // TODO: 팀원 구현 — 스트리밍 생성 상태 연동
            ],
          ),
        ),
        // Input row
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            border:
                Border(top: BorderSide(color: AppColors.stone200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: '노트 내용에 대해 질문하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.xl),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm),
                    filled: true,
                    fillColor: AppColors.stone50,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  // TODO: 팀원 구현 — RAG Q&A 입력 연동
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
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
    // TODO: 팀원 구현 — RAG Q&A API 호출
    _inputController.clear();
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
    final colorScheme = Theme.of(context).colorScheme;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(
              bottom: AppSpacing.sm, left: AppSpacing.xxl),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.md),
              topRight: Radius.circular(AppSpacing.md),
              bottomLeft: Radius.circular(AppSpacing.md),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.xxs),
              Text(message.time,
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
            bottom: AppSpacing.sm, right: AppSpacing.xxl),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.stone100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.md),
            topRight: Radius.circular(AppSpacing.md),
            bottomRight: Radius.circular(AppSpacing.md),
          ),
          border: Border.all(color: AppColors.stone200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 14, color: AppColors.primaryAmber),
                const SizedBox(width: AppSpacing.xs),
                Text('Synapse AI',
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppColors.stone500)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _AnimatedTypingText(text: message.text, style: textTheme.bodyMedium),
            if (message.sources.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  Text('인용 소스:',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.stone500)),
                  ...message.sources.map((src) => ActionChip(
                        label: Text(src,
                            style: textTheme.bodySmall?.copyWith(fontSize: 11)),
                        avatar: const Icon(Icons.description_outlined, size: 14),
                        onPressed: () {
                          // TODO: 팀원 구현 — 소스 노트로 이동
                        },
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
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
                  color: AppColors.stone400,
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
                  color: AppColors.stone400,
                  tooltip: '싫어요',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(AppSpacing.xs),
                ),
                const Spacer(),
                Text(message.time,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTypingText extends StatefulWidget {
  const _AnimatedTypingText({
    required this.text,
    this.style,
  });
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
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _charCount = 0;
      _startTyping();
    }
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_charCount >= widget.text.length) {
        timer.cancel();
        return;
      }
      setState(() => _charCount++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _charCount),
      style: widget.style,
    );
  }
}
