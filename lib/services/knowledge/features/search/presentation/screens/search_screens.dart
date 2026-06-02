import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
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
  bool _hasQuery = false;
  bool _semantic = true;

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
                  onChanged: (v) => setState(() => _hasQuery = v.isNotEmpty),
                ),
              ),
              if (_hasQuery)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  color: AppColors.muted,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _hasQuery = false);
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
              selected: _semantic,
              onTap: () => setState(() => _semantic = true),
            ),
            const SizedBox(width: AppSpacing.sm),
            ConceptFilterPill(
              label: '키워드',
              selected: !_semantic,
              onTap: () => setState(() => _semantic = false),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _semantic
              ? '키워드를 넘어 의미로 — pgvector + Elasticsearch 하이브리드'
              : '제목·본문 키워드 일치 검색',
          style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
        ),
        if (!_hasQuery)
          const ConceptEmptyState(
            emoji: '🔍',
            title: '검색어를 입력하세요',
            body: '노트, 카드, 태그를 한번에 검색할 수 있습니다',
          )
        else ...[
          // 의미 검색일 때 AI 답변 카드
          if (_semantic) ...[
            const ConceptSectionLabel('AI 답변'),
            ConceptGradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SynapseOrb(size: 26, glyphScale: 0.5),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'AI 답변',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '정규화는 과적합을 막기 위한 기법입니다. L1(Lasso)은 일부 가중치를 0으로 만들어 feature selection 효과를 주고, L2(Ridge)는 가중치를 작게 유지합니다. 신경망에서는 드롭아웃도 정규화 역할을 합니다.',
                    style: textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  const Wrap(
                    spacing: AppSpacing.xs + 2,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _SourceChip('ML 정규화 기법'),
                      _SourceChip('Lasso'),
                      _SourceChip('Ridge'),
                      _SourceChip('과적합'),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const ConceptSectionLabel('관련 결과'),
          for (final result in _mockResults)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ConceptCard(
                onTap: () => context.go(
                  AppRoutes.noteDetailPath(result['id'] as String),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: _highlightText(
                                result['title'] as String,
                                _searchController.text,
                                textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          result['time'] as String,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
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
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs + 2,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final tag in result['tags'] as List<String>)
                          ConceptTag('#$tag'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
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

  // TODO: 팀원 구현 — RAG Q&A API 연동 (스트리밍)
  final List<_ChatMessage> _messages = [
    const _ChatMessage(isUser: true, text: '정규화 기법에 대해 설명해줘', time: '14:30'),
    const _ChatMessage(
      isUser: false,
      text:
          'L1/L2 정규화는 과적합(Overfitting)을 방지하기 위한 기법입니다.\n\n'
          'L1 정규화 (Lasso)\n'
          '- 가중치의 절댓값 합을 페널티로 추가합니다\n'
          '- 일부 가중치를 0으로 만들어 희소성을 유도합니다\n\n'
          'L2 정규화 (Ridge)\n'
          '- 가중치의 제곱합을 페널티로 추가합니다\n'
          '- 가중치를 작게 유지하되 완전히 0으로 만들지 않습니다',
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
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '● 답변 중',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Messages list
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _messages.length,
                itemBuilder: (context, i) => _ChatBubble(message: _messages[i]),
              ),
            ),
          ),
        ),
        // Streaming indicator placeholder
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
                style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
              // TODO: 팀원 구현 — 스트리밍 생성 상태 연동
            ],
          ),
        ),
        // Input row
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
                  decoration: InputDecoration(
                    hintText: '노트 내용에 대해 질문하세요…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    filled: true,
                    fillColor: AppColors.surface2,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  // TODO: 팀원 구현 — RAG Q&A 입력 연동
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: _sendMessage,
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
