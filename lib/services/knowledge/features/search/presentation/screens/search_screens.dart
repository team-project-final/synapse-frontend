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

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = '노트';
  bool _hasQuery = false;

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final filters = ['노트', '카드', '태그', 'AI 검색'];

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
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: filters.map((f) {
              final selected = _selectedFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: FilterChip(
                  label: Text(f),
                  selected: selected,
                  selectedColor: colorScheme.primaryContainer,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
                                    child: Text(
                                        result['title'] as String,
                                        style: textTheme.titleSmall),
                                  ),
                                  Text(result['time'] as String,
                                      style: textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppColors.stone400)),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(result['snippet'] as String,
                                  style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.stone500),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
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
    _ChatMessage(
      isUser: true,
      text: '정규화 기법에 대해 설명해줘',
      time: '14:30',
    ),
    _ChatMessage(
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
  });
  final bool isUser;
  final String text;
  final String time;
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
            Text(message.text, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xxs),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(message.time,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.stone400)),
            ),
          ],
        ),
      ),
    );
  }
}
