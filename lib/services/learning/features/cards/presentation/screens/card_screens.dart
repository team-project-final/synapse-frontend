import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/ai_generate_loading.dart';
import 'package:synapse_frontend/shared/widgets/concept.dart';
import 'package:synapse_frontend/shared/widgets/flip_card.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

// ── Mock data ──

class _MockDeck {
  const _MockDeck({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cardCount,
    required this.dueCount,
    required this.progress,
  });
  final String id;
  final String name;
  final String emoji;
  final int cardCount;
  final int dueCount;
  final double progress;
}

const _mockDecks = [
  _MockDeck(
      id: '1',
      name: '프로그래밍 기초',
      emoji: '💻',
      cardCount: 45,
      dueCount: 12,
      progress: 0.6),
  _MockDeck(
      id: '2',
      name: '알고리즘 & 자료구조',
      emoji: '🧩',
      cardCount: 80,
      dueCount: 5,
      progress: 0.75),
  _MockDeck(
      id: '3',
      name: 'AWS 자격증',
      emoji: '☁️',
      cardCount: 30,
      dueCount: 20,
      progress: 0.3),
];

// ── DeckListScreen (SCR-W-CARD-001) ──

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return ConceptPage(
      children: [
        Row(
          children: [
            const Expanded(child: ConceptViewHead(title: '내 덱', meta: '덱 3')),
            FilledButton.icon(
              onPressed: () {
                // TODO: 팀원 구현 — 새 덱 생성 다이얼로그/화면
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('새 덱'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Deck cards
        // TODO: 팀원 구현 — learning-svc 덱 목록 API 연동
        ConceptResponsiveGrid(
          isWide: isWide,
          children: [for (final deck in _mockDecks) _DeckCard(deck: deck)],
        ),
        const SizedBox(height: AppSpacing.xl),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ConceptCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(deck.emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    deck.name,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
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
                        backgroundColor: AppColors.surface2,
                        color: AppColors.primary,
                      ),
                      Text(
                        '${(deck.progress * 100).toInt()}%',
                        style: textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _CountChip(
                  label: '${deck.cardCount}장',
                  icon: Icons.style_outlined,
                  color: AppColors.muted,
                ),
                _CountChip(
                  label: '${deck.dueCount}개 복습 대기',
                  icon: Icons.schedule,
                  color: deck.dueCount > 10
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: deck.progress,
                minHeight: 7,
                backgroundColor: AppColors.surface2,
                color: AppColors.primary,
              ),
            ),
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
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('하위 덱',
                    style: textTheme.labelMedium?.copyWith(
                        color: AppColors.muted, fontWeight: FontWeight.w700)),
                children: [
                  _SubDeckTile(
                      name: '${deck.name} - 기본', count: deck.cardCount ~/ 2),
                  _SubDeckTile(
                      name: '${deck.name} - 심화',
                      count: deck.cardCount - deck.cardCount ~/ 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubDeckTile extends StatelessWidget {
  const _SubDeckTile({required this.name, required this.count});
  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.folder_outlined,
          size: 18, color: AppColors.muted),
      title: Text(name, style: textTheme.bodySmall),
      trailing: Text('$count장',
          style: textTheme.labelSmall?.copyWith(color: AppColors.muted)),
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
            style: textTheme.labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700)),
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
  String _selectedSort = '최신순';
  String _selectedType = '전체';
  final Set<int> _checkedCards = {};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sortOptions = ['최신순', '난이도순', '복습순'];

    // TODO: 팀원 구현 — learning-svc 카드 목록 API 연동 (deckId: ${widget.deckId})
    final mockCards = [
      {
        'front': 'L1 정규화와 L2 정규화의 차이점은?',
        'back': 'L1은 절댓값 합(Lasso), L2는 제곱합(Ridge). L1은 희소성 유도.',
        'type': 'Basic',
      },
      {
        'front': '동적 프로그래밍의 두 가지 접근법은?',
        'back': '탑다운(메모이제이션)과 바텀업(타뷸레이션)',
        'type': 'Basic',
      },
      {
        'front': 'Big O 표기법에서 O(n log n)의 의미는?',
        'back': '병합 정렬, 힙 정렬 등의 시간 복잡도. 선형로그 복잡도.',
        'type': 'Cloze',
      },
      {
        'front': 'AWS S3 버킷 정책과 IAM 정책의 차이?',
        'back': 'S3 버킷 정책은 리소스 기반, IAM은 사용자/역할 기반 정책',
        'type': 'Basic',
      },
    ];

    return ConceptPage(
      children: [
        const ConceptViewHead(title: '카드', meta: '카드 4'),
        ConceptSearchBar(hint: '카드 검색…', onTap: () {}),
        const SizedBox(height: AppSpacing.md),
        // Sort pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final s in sortOptions) ...[
                ConceptFilterPill(
                  label: s,
                  selected: _selectedSort == s,
                  onTap: () => setState(() => _selectedSort = s),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Type filter pills
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final type in ['전체', 'Basic', 'Cloze'])
              ConceptFilterPill(
                label: type,
                selected: _selectedType == type,
                onTap: () => setState(() => _selectedType = type),
              ),
          ],
        ),
        if (_checkedCards.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {
                // TODO: 팀원 구현 — 선택 카드 삭제 API 연동
                setState(() => _checkedCards.clear());
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text('선택 삭제 (${_checkedCards.length})'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            ),
          ),
        ],
        const ConceptSectionLabel('카드 목록', topGap: AppSpacing.md),
        for (final entry in mockCards.asMap().entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ConceptCard(
              child: Row(
                children: [
                  Checkbox(
                    value: _checkedCards.contains(entry.key),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _checkedCards.add(entry.key);
                        } else {
                          _checkedCards.remove(entry.key);
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ConceptTag(entry.value['type']!.toLowerCase()),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(entry.value['front']!,
                            style: textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(entry.value['back']!,
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.muted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.muted, size: 20),
                    onPressed: () => context.go(AppRoutes.cardNew),
                    // TODO: 팀원 구현 — 카드 편집 화면 연동
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
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
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  OutlineInputBorder get _inputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      );

  @override
  Widget build(BuildContext context) {
    return ConceptPage(
      children: [
        const ConceptViewHead(title: '카드 생성'),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'basic', label: Text('Basic')),
            ButtonSegment(value: 'cloze', label: Text('Cloze')),
          ],
          selected: {_cardType},
          onSelectionChanged: (s) => setState(() => _cardType = s.first),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _frontController,
          decoration: InputDecoration(
            labelText: '앞면 (질문)',
            hintText: '앞면 (질문)',
            filled: true,
            fillColor: AppColors.surface,
            border: _inputBorder,
            enabledBorder: _inputBorder,
          ),
          // TODO: 팀원 구현 — 카드 앞면 데이터 연동
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _backController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '뒷면 (정답)',
            hintText: '뒷면 (정답)',
            filled: true,
            fillColor: AppColors.surface,
            border: _inputBorder,
            enabledBorder: _inputBorder,
          ),
          // TODO: 팀원 구현 — 카드 뒷면 데이터 연동
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: _selectedDeck,
          decoration: InputDecoration(
            labelText: '덱 선택',
            filled: true,
            fillColor: AppColors.surface,
            border: _inputBorder,
            enabledBorder: _inputBorder,
          ),
          items: const [
            DropdownMenuItem(value: '프로그래밍 기초', child: Text('프로그래밍 기초')),
            DropdownMenuItem(value: '알고리즘', child: Text('알고리즘')),
          ],
          onChanged: (v) => setState(() => _selectedDeck = v),
          // TODO: 팀원 구현 — learning-svc 덱 목록 API 연동
        ),
        const ConceptSectionLabel('태그'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final tag in ['머신러닝', '알고리즘', 'AWS', '프로그래밍'])
              ConceptFilterPill(
                label: tag,
                selected: _selectedTags.contains(tag),
                onTap: () => setState(() {
                  if (!_selectedTags.add(tag)) _selectedTags.remove(tag);
                }),
              ),
          ],
        ),
        const ConceptSectionLabel('이미지'),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 32, color: AppColors.muted),
                SizedBox(height: AppSpacing.xs),
                Text('이미지 추가',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () {
            // TODO: 팀원 구현 — learning-svc 카드 저장 API 연동
            context.go(AppRoutes.decks);
          },
          child: const Text('저장'),
        ),
        const SizedBox(height: AppSpacing.xl),
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
    {'front': 'L1 정규화의 다른 이름은?', 'back': 'Lasso', 'type': 'basic'},
    {'front': 'L2 정규화의 다른 이름은?', 'back': 'Ridge', 'type': 'basic'},
    {'front': '정규화의 주요 목적은?', 'back': '과적합 방지', 'type': 'cloze'},
    {'front': 'L1 정규화가 유도하는 성질은?', 'back': '희소성(Sparsity)', 'type': 'basic'},
    {'front': 'Dropout이란?', 'back': '뉴런을 랜덤하게 비활성화', 'type': 'basic'},
    {'front': 'Batch Normalization의 역할은?', 'back': '학습 안정성 향상', 'type': 'basic'},
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return ConceptPage(
      children: [
        // 히어로
        Row(
          children: [
            const SynapseOrb(size: 48, glyphScale: 0.46, shadow: true),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI 카드 생성',
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text('노트를 골라 복습 카드를 자동으로 만들어요',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
        const ConceptSectionLabel('노트 선택'),
        ConceptCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < _mockNotes.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                RadioListTile<String>(
                  value: _mockNotes[i]['id']!,
                  // ignore: deprecated_member_use
                  groupValue: _selectedNote,
                  title: Text(_mockNotes[i]['title']!,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  activeColor: AppColors.primary,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _selectedNote = v),
                ),
              ],
            ],
          ),
        ),
        const ConceptSectionLabel('카드 수'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final count in [5, 10, 15, 20]) ...[
                ConceptFilterPill(
                  label: '$count장',
                  selected: _cardCount == count,
                  onTap: () => setState(() => _cardCount = count),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: _selectedNote != null && !_isGenerating
              ? () {
                  setState(() {
                    _isGenerating = true;
                    _hasResults = false;
                    _selectedResults.clear();
                  });
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
        const ConceptSectionLabel('생성 결과'),
        if (_isGenerating)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: AIGenerateLoading(),
          )
        else if (_hasResults) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 2 : 1,
              mainAxisSpacing: AppSpacing.sm + 2,
              crossAxisSpacing: AppSpacing.sm + 2,
              mainAxisExtent: 132,
            ),
            itemCount: _mockGeneratedCards.length,
            itemBuilder: (context, i) {
              final card = _mockGeneratedCards[i];
              final isChecked = _selectedResults.contains(i);
              return ConceptCard(
                highlightBorder: isChecked,
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _selectedResults.remove(i);
                    } else {
                      _selectedResults.add(i);
                    }
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ConceptTag(card['type']!),
                        const Spacer(),
                        Icon(
                          isChecked
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 20,
                          color:
                              isChecked ? AppColors.primary : AppColors.border,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Text('Q. ${card['front']!}',
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.xxs),
                    Expanded(
                      child: Text('A. ${card['back']!}',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
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
              icon: const Icon(Icons.save_outlined),
              label: Text('덱에 추가 (${_selectedResults.length})'),
            ),
          ],
        ] else
          const ConceptEmptyState(
            emoji: '✨',
            title: '생성 결과가 여기에 표시됩니다',
            body: '노트를 선택하고 AI 카드 생성 버튼을 눌러 시작하세요',
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ── ReviewScreen (FlipCard) ──

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Progress row
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.muted),
                onPressed: () => context.go(AppRoutes.decks),
                tooltip: '종료',
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: const LinearProgressIndicator(
                    value: 1 / 20,
                    minHeight: 7,
                    backgroundColor: AppColors.surface2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('1 / 20',
                  style: textTheme.labelLarge?.copyWith(
                      color: AppColors.muted, fontWeight: FontWeight.w700)),
            ],
          ),
        ),

        // Card area
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 260,
                      child: FlipCard(
                        front: _FlashFace(
                          label: '카드 앞면 (질문)',
                          hint: '👆 탭하여 정답 확인',
                        ),
                        back: _FlashFace(
                          label: '카드 뒷면 (정답)',
                          highlighted: true,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    // AI 힌트
                    ConceptAiComment(
                      text: '힌트: 모델이 학습 데이터를 "외워버린" 상황을 떠올려 보세요. 새로운 데이터에서는 어떻게 될까요?',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Difficulty buttons (SM-2 rating)
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Row(
            children: [
              _RateButton(
                  label: '다시',
                  sub: '<1분',
                  color: AppColors.error,
                  onTap: () {
                    // TODO: 팀원 구현 — SM-2 rating API 호출
                  }),
              const SizedBox(width: AppSpacing.sm),
              _RateButton(
                  label: '어려움',
                  sub: '4일',
                  color: AppColors.warning,
                  onTap: () {}),
              const SizedBox(width: AppSpacing.sm),
              _RateButton(
                  label: '보통',
                  sub: '9일',
                  color: AppColors.success,
                  onTap: () {}),
              const SizedBox(width: AppSpacing.sm),
              _RateButton(
                  label: '쉬움',
                  sub: '21일',
                  color: AppColors.accent,
                  onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlashFace extends StatelessWidget {
  const _FlashFace({
    required this.label,
    this.hint,
    this.highlighted = false,
  });

  final String label;
  final String? hint;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.border,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            // TODO: 팀원 구현 — learning-svc 카드 데이터 연동
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(hint!,
                  style:
                      textTheme.bodySmall?.copyWith(color: AppColors.muted)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  const _RateButton({
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
            child: Column(
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
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
    return ConceptPage(
      children: [
        const SizedBox(height: AppSpacing.md),
        // 결과 orb
        const Center(
          child: SynapseOrb(size: 84, glyph: '🎉', glyphScale: 0.48, shadow: true),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text('복습 완료!',
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text('오늘 25장을 모두 끝냈어요',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Streak bar
        Container(
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          decoration: BoxDecoration(
            color: AppColors.streak.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.streak.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Text('14일',
                  style: textTheme.titleMedium?.copyWith(
                      color: AppColors.streak, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Text('연속 학습 중!',
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Stats
        const ConceptStatRow(
          children: [
            ConceptStat(value: '+85', label: '획득 XP', color: AppColors.primary),
            ConceptStat(value: '25', label: '복습 카드'),
            ConceptStat(value: '80%', label: '정답률', color: AppColors.success),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // AI comment
        const ConceptAiComment(
          text: '정답률이 지난주보다 6%p 올랐어요! 다만 「과적합」 관련 카드에서 막혔으니, 내일은 그 노트를 한 번 더 보면 좋겠어요. 🙌',
        ),
        // Accuracy donut chart
        const ConceptSectionLabel('정확도'),
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutChartPainter(
                correctRatio: 0.78,
                correctColor: AppColors.primary,
                incorrectColor: AppColors.surface2,
              ),
              child: Center(
                child: Text('78%',
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
        // Next review schedule
        const ConceptSectionLabel('다음 복습 예정'),
        ConceptCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < _kNextReviews.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule,
                      size: 18, color: AppColors.muted),
                  title: Text(_kNextReviews[i]['title']!,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  trailing: Text(_kNextReviews[i]['date']!,
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppColors.muted)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => context.go(AppRoutes.dashboard),
          child: const Text('대시보드로 이동'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.review),
          child: const Text('다시 시작'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

const _kNextReviews = [
  {'title': 'L1 정규화란?', 'date': '2026-05-22'},
  {'title': '동적 프로그래밍 정의', 'date': '2026-05-23'},
  {'title': 'AWS S3 버킷 정책 차이', 'date': '2026-05-25'},
];

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

    paint.color = incorrectColor;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 2 * math.pi, false, paint);

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
