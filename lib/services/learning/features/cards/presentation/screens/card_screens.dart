import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/ai_generate_loading.dart';
import 'package:synapse_frontend/shared/widgets/flip_card.dart';

// ── Mock data ──

class _MockDeck {
  const _MockDeck({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.dueCount,
    required this.progress,
  });
  final String id;
  final String name;
  final int cardCount;
  final int dueCount;
  final double progress;
}

const _mockDecks = [
  _MockDeck(
      id: '1',
      name: '프로그래밍 기초',
      cardCount: 45,
      dueCount: 12,
      progress: 0.6),
  _MockDeck(
      id: '2',
      name: '알고리즘 & 자료구조',
      cardCount: 80,
      dueCount: 5,
      progress: 0.75),
  _MockDeck(
      id: '3', name: 'AWS 자격증', cardCount: 30, dueCount: 20, progress: 0.3),
];

// ── DeckListScreen (SCR-W-CARD-001) ──

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Header
        Row(
          children: [
            Text('내 덱', style: textTheme.titleLarge),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                // TODO: 팀원 구현 — 새 덱 생성 다이얼로그/화면
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('새 덱'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Deck cards
        // TODO: 팀원 구현 — learning-svc 덱 목록 API 연동
        ..._mockDecks.map((deck) => _DeckCard(deck: deck)),
      ],
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.deck});
  final _MockDeck deck;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(deck.name, style: textTheme.titleMedium),
                ),
                // Mastery circular indicator
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: deck.progress,
                        strokeWidth: 4,
                        backgroundColor: AppColors.stone200,
                        color: colorScheme.primary,
                      ),
                      Text(
                        '${(deck.progress * 100).toInt()}%',
                        style: textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _CountChip(
                  label: '${deck.cardCount}장',
                  icon: Icons.style_outlined,
                  color: AppColors.stone500,
                ),
                const SizedBox(width: AppSpacing.sm),
                _CountChip(
                  label: '${deck.dueCount}개 복습 대기',
                  icon: Icons.schedule,
                  color: deck.dueCount > 10
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: deck.progress,
              backgroundColor: AppColors.stone200,
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('${(deck.progress * 100).toInt()}% 완료',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.stone500)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.go(AppRoutes.review),
                    child: const Text('복습 시작'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.go(AppRoutes.deckCardsPath(deck.id)),
                    child: const Text('카드 보기'),
                  ),
                ),
              ],
            ),
            // Sub-decks
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('하위 덱', style: textTheme.bodySmall?.copyWith(color: AppColors.stone500)),
              children: [
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.folder_outlined, size: 18, color: AppColors.stone400),
                  title: Text('${deck.name} - 기본', style: textTheme.bodySmall),
                  trailing: Text('${deck.cardCount ~/ 2}장', style: textTheme.bodySmall?.copyWith(color: AppColors.stone400)),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.folder_outlined, size: 18, color: AppColors.stone400),
                  title: Text('${deck.name} - 심화', style: textTheme.bodySmall),
                  trailing: Text('${deck.cardCount - deck.cardCount ~/ 2}장', style: textTheme.bodySmall?.copyWith(color: AppColors.stone400)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(label,
            style: textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}

// ── CardListScreen (SCR-W-CARD-002) ──

class CardListScreen extends ConsumerStatefulWidget {
  const CardListScreen({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends ConsumerState<CardListScreen> {
  final _searchController = TextEditingController();
  String _selectedSort = '최신순';
  String _selectedType = '전체';
  final Set<int> _checkedCards = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final sortOptions = ['최신순', '난이도순', '복습순'];

    // TODO: 팀원 구현 — learning-svc 카드 목록 API 연동 (deckId: ${widget.deckId})
    final mockCards = [
      {
        'front': 'L1 정규화와 L2 정규화의 차이점은?',
        'back': 'L1은 절댓값 합(Lasso), L2는 제곱합(Ridge). L1은 희소성 유도.'
      },
      {
        'front': '동적 프로그래밍의 두 가지 접근법은?',
        'back': '탑다운(메모이제이션)과 바텀업(타뷸레이션)'
      },
      {
        'front': 'Big O 표기법에서 O(n log n)의 의미는?',
        'back': '병합 정렬, 힙 정렬 등의 시간 복잡도. 선형로그 복잡도.'
      },
      {
        'front': 'AWS S3 버킷 정책과 IAM 정책의 차이?',
        'back': 'S3 버킷 정책은 리소스 기반, IAM은 사용자/역할 기반 정책'
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '카드 검색...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            filled: true,
            fillColor: AppColors.stone50,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Sort chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sortOptions.map((s) {
              final selected = _selectedSort == s;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: FilterChip(
                  label: Text(s),
                  selected: selected,
                  selectedColor: colorScheme.primaryContainer,
                  onSelected: (_) => setState(() => _selectedSort = s),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Card type filter
        Row(
          children: ['전체', 'Basic', 'Cloze'].map((type) {
            final selected = _selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: FilterChip(
                label: Text(type),
                selected: selected,
                selectedColor: colorScheme.primaryContainer,
                onSelected: (_) => setState(() => _selectedType = type),
              ),
            );
          }).toList(),
        ),
        if (_checkedCards.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () {
              // TODO: 팀원 구현 — 선택 카드 삭제 API 연동
              setState(() => _checkedCards.clear());
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text('선택 삭제 (${_checkedCards.length})'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ...mockCards.asMap().entries.map((entry) {
          final i = entry.key;
          final card = entry.value;
          return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Checkbox(
                      value: _checkedCards.contains(i),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _checkedCards.add(i);
                          } else {
                            _checkedCards.remove(i);
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card['front']!,
                              style: textTheme.bodyMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(card['back']!,
                              style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.stone500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.stone400),
                      onPressed: () =>
                          context.go(AppRoutes.cardNew),
                      // TODO: 팀원 구현 — 카드 편집 화면 연동
                    ),
                  ],
                ),
              ),
            );
        }),
      ],
    );
  }
}

// ── CardEditorScreen (SCR-W-CARD-003) ──

class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({super.key});

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  String _cardType = 'basic';
  String? _selectedDeck = '프로그래밍 기초';

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('카드 생성', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        // Card type segmented button
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'basic', label: Text('Basic')),
            ButtonSegment(value: 'cloze', label: Text('Cloze')),
          ],
          selected: {_cardType},
          onSelectionChanged: (s) => setState(() => _cardType = s.first),
        ),
        const SizedBox(height: AppSpacing.md),
        // Front
        TextFormField(
          controller: _frontController,
          decoration: InputDecoration(
            labelText: '앞면 (질문)',
            hintText: '앞면 (질문)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          // TODO: 팀원 구현 — 카드 앞면 데이터 연동
        ),
        const SizedBox(height: AppSpacing.md),
        // Back
        TextFormField(
          controller: _backController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '뒷면 (정답)',
            hintText: '뒷면 (정답)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          // TODO: 팀원 구현 — 카드 뒷면 데이터 연동
        ),
        const SizedBox(height: AppSpacing.md),
        // Deck selection
        DropdownButtonFormField<String>(
          initialValue: _selectedDeck,
          decoration: InputDecoration(
            labelText: '덱 선택',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
          ),
          items: const [
            DropdownMenuItem(value: '프로그래밍 기초', child: Text('프로그래밍 기초')),
            DropdownMenuItem(value: '알고리즘', child: Text('알고리즘')),
          ],
          onChanged: (v) => setState(() => _selectedDeck = v),
          // TODO: 팀원 구현 — learning-svc 덱 목록 API 연동
        ),
        const SizedBox(height: AppSpacing.md),
        // Tags
        Text('태그', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          children: ['머신러닝', '알고리즘', 'AWS', '프로그래밍']
              .map((tag) => FilterChip(
                    label: Text(tag),
                    selected: false,
                    onSelected: (_) {
                      // TODO: 팀원 구현 — 태그 선택 로직
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        // Image add area
        Text('이미지', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(color: AppColors.stone300),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt_outlined,
                    size: 32, color: AppColors.stone400),
                const SizedBox(height: AppSpacing.xs),
                Text('이미지 추가',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone400)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Save button
        FilledButton(
          onPressed: () {
            // TODO: 팀원 구현 — learning-svc 카드 저장 API 연동
            context.go(AppRoutes.decks);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

// ── AiCardGenerationScreen (SCR-W-CARD-004) ──

class AiCardGenerationScreen extends ConsumerStatefulWidget {
  const AiCardGenerationScreen({super.key});

  @override
  ConsumerState<AiCardGenerationScreen> createState() =>
      _AiCardGenerationScreenState();
}

class _AiCardGenerationScreenState
    extends ConsumerState<AiCardGenerationScreen> {
  String? _selectedNote;
  int _cardCount = 10;
  bool _isGenerating = false;
  bool _hasResults = false;
  final Set<int> _selectedResults = {};

  // TODO: 팀원 구현 — knowledge-svc 노트 목록 API 연동
  final _mockNotes = [
    {'id': '1', 'title': '정규화 기법 (Regularization)'},
    {'id': '2', 'title': '동적 프로그래밍 기초'},
    {'id': '3', 'title': 'AWS S3 버킷 정책'},
  ];

  static const _mockGeneratedCards = [
    {'front': 'L1 정규화의 다른 이름은?', 'back': 'Lasso'},
    {'front': 'L2 정규화의 다른 이름은?', 'back': 'Ridge'},
    {'front': '정규화의 주요 목적은?', 'back': '과적합 방지'},
    {'front': 'L1 정규화가 유도하는 성질은?', 'back': '희소성(Sparsity)'},
    {'front': 'Dropout이란?', 'back': '뉴런을 랜덤하게 비활성화'},
    {'front': 'Batch Normalization의 역할은?', 'back': '학습 안정성 향상'},
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('AI 카드 생성', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        // Note selection section
        Text('노트 선택', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: _mockNotes
                .map((note) => RadioListTile<String>(
                      value: note['id']!,
                      groupValue: _selectedNote,
                      title: Text(note['title']!,
                          style: textTheme.bodyMedium),
                      onChanged: (v) =>
                          setState(() => _selectedNote = v),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Card count section
        Text('카드 수', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [5, 10, 15, 20].map((count) {
              final selected = _cardCount == count;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text('$count장'),
                  selected: selected,
                  selectedColor: colorScheme.primaryContainer,
                  onSelected: (_) =>
                      setState(() => _cardCount = count),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Generate button
        FilledButton.icon(
          onPressed: _selectedNote != null && !_isGenerating
              ? () {
                  setState(() {
                    _isGenerating = true;
                    _hasResults = false;
                    _selectedResults.clear();
                  });
                  // Simulate generation delay
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _isGenerating = false;
                        _hasResults = true;
                      });
                    }
                  });
                }
              : null,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('AI 카드 생성'),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Preview section
        Text('생성 결과', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (_isGenerating)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: AIGenerateLoading(),
          )
        else if (_hasResults) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.4,
            ),
            itemCount: _mockGeneratedCards.length,
            itemBuilder: (context, i) {
              final card = _mockGeneratedCards[i];
              final isChecked = _selectedResults.contains(i);
              return Card(
                color: isChecked ? colorScheme.primaryContainer : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isChecked) {
                        _selectedResults.remove(i);
                      } else {
                        _selectedResults.add(i);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isChecked,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedResults.add(i);
                                    } else {
                                      _selectedResults.remove(i);
                                    }
                                  });
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        Text(card['front']!,
                            style: textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(card['back']!,
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.stone500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selectedResults.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () {
                // TODO: 팀원 구현 — 선택 카드 저장 API 연동
                context.go(AppRoutes.decks);
              },
              icon: const Icon(Icons.save),
              label: Text('선택 저장 (${_selectedResults.length})'),
            ),
          ],
        ] else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.stone100,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: AppColors.stone200),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_outlined,
                      size: 48, color: AppColors.stone300),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '생성 결과가 여기에 표시됩니다',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.stone400),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'AI 카드 생성 버튼을 눌러 시작하세요',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.stone300),
                  ),
                  // TODO: 팀원 구현 — AI 생성 스트리밍 연동
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── ReviewScreen (FlipCard) — DO NOT CHANGE ──

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text('1 / 20', style: textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go(AppRoutes.decks),
                tooltip: '종료',
              ),
            ],
          ),
        ),
        const LinearProgressIndicator(value: 1 / 20),

        // Card area
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FlipCard(
                  front: Card(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('카드 앞면 (질문)',
                                style: textTheme.headlineSmall,
                                textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.lg),
                            Text('탭하여 뒤집기',
                                style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.stone400)),
                            // TODO: 팀원 구현 — learning-svc 카드 데이터 연동
                          ],
                        ),
                      ),
                    ),
                  ),
                  back: Card(
                    color: colorScheme.primaryContainer,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('카드 뒷면 (정답)',
                                style: textTheme.headlineSmall,
                                textAlign: TextAlign.center),
                            // TODO: 팀원 구현 — learning-svc 카드 데이터 연동
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Difficulty buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Row(
            children: [
              _DifficultyButton(
                  label: 'Again',
                  color: AppColors.error,
                  onTap: () {
                    // TODO: 팀원 구현 — SM-2 rating API 호출
                  }),
              const SizedBox(width: AppSpacing.sm),
              _DifficultyButton(
                  label: 'Hard',
                  color: AppColors.warning,
                  onTap: () {}),
              const SizedBox(width: AppSpacing.sm),
              _DifficultyButton(
                  label: 'Good',
                  color: AppColors.success,
                  onTap: () {}),
              const SizedBox(width: AppSpacing.sm),
              _DifficultyButton(
                  label: 'Easy',
                  color: AppColors.info,
                  onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: color),
        child: Text(label),
      ),
    );
  }
}

// ── ReviewResultScreen (SCR-W-CARD-006) ──

class ReviewResultScreen extends ConsumerWidget {
  const ReviewResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // TODO: 팀원 구현 — learning-svc 세션 결과 데이터 연동
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        // Celebration icon
        Center(
          child: Icon(
            Icons.celebration,
            size: 80,
            color: AppColors.primaryAmber,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text('세션 완료!', style: textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Stats row
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: '총 카드', value: '25'),
                _StatDivider(),
                _StatItem(label: '정확도', value: '80%'),
                _StatDivider(),
                _StatItem(label: '소요 시간', value: '12분'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Progress
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('정확도', style: textTheme.bodyMedium),
                Text('80%',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.success)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: 0.8,
              backgroundColor: AppColors.stone200,
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              minHeight: 8,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Next review
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.stone400),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '다음 복습: 내일',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.stone500),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Accuracy donut chart
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutChartPainter(
                correctRatio: 0.78,
                correctColor: AppColors.primaryAmber,
                incorrectColor: AppColors.stone200,
              ),
              child: Center(
                child: Text('78%',
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Next review schedule
        Text('다음 복습 예정', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ...[
          {'title': 'L1 정규화란?', 'date': '2026-05-22'},
          {'title': '동적 프로그래밍 정의', 'date': '2026-05-23'},
          {'title': 'AWS S3 버킷 정책 차이', 'date': '2026-05-25'},
        ].map((item) => ListTile(
              dense: true,
              leading: const Icon(Icons.schedule, size: 18, color: AppColors.stone400),
              title: Text(item['title']!, style: textTheme.bodyMedium),
              trailing: Text(item['date']!, style: textTheme.bodySmall?.copyWith(color: AppColors.stone500)),
            )),
        const SizedBox(height: AppSpacing.xl),
        // Buttons
        FilledButton(
          onPressed: () => context.go(AppRoutes.dashboard),
          child: const Text('대시보드로 이동'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.review),
          child: const Text('다시 시작'),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value,
            style: textTheme.headlineSmall
                ?.copyWith(color: AppColors.primaryAmber)),
        const SizedBox(height: AppSpacing.xxs),
        Text(label,
            style: textTheme.bodySmall?.copyWith(color: AppColors.stone500)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.stone200,
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.correctRatio,
    required this.correctColor,
    required this.incorrectColor,
  });

  final double correctRatio;
  final Color correctColor;
  final Color incorrectColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const strokeWidth = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background arc (incorrect)
    paint.color = incorrectColor;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 2 * math.pi, false, paint);

    // Correct arc
    paint.color = correctColor;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * correctRatio,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.correctRatio != correctRatio;
}
