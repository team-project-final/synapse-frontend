import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
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
    this.description = '',
  });
  final String id;
  final String name;
  final String emoji;
  final int cardCount;
  final int dueCount;
  final double progress;
  final String description;
}

const _mockDecks = [
  _MockDeck(
    id: '1',
    name: '프로그래밍 기초',
    emoji: '💻',
    cardCount: 45,
    dueCount: 12,
    progress: 0.6,
    description: '자료구조·언어 문법 등 기초 개념 정리 덱',
  ),
  _MockDeck(
    id: '2',
    name: '알고리즘 & 자료구조',
    emoji: '🧩',
    cardCount: 80,
    dueCount: 5,
    progress: 0.75,
    description: 'DP·그래프·정렬 등 핵심 알고리즘 모음',
  ),
  _MockDeck(
    id: '3',
    name: 'AWS 자격증',
    emoji: '☁️',
    cardCount: 30,
    dueCount: 20,
    progress: 0.3,
    description: 'SAA 대비 핵심 서비스 요약',
  ),
];

// ── DeckListScreen (SCR-W-CARD-001) ──

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    // 1차 액션(새 덱)은 노트 화면과 동일하게 FAB로 분리, 헤더 우측엔 개수만.
    return Stack(
      children: [
        ConceptPage(
          children: [
            ConceptViewHead(title: '내 덱', meta: '총 ${_mockDecks.length}개'),
            const SizedBox(height: AppSpacing.sm),
            // Deck cards
            // TODO: 팀원 구현 — learning-svc 덱 목록 API 연동
            ConceptResponsiveGrid(
              isWide: isWide,
              children: [for (final deck in _mockDecks) _DeckCard(deck: deck)],
            ),
            // FAB에 마지막 카드가 가리지 않도록 하단 여백 확보.
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
          ],
        ),
        Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: FloatingActionButton.extended(
            onPressed: () => context.go(AppRoutes.deckNew),
            icon: const Icon(Icons.add),
            label: const Text('새 덱'),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DeckCreateScreen — 새 덱 생성 폼(/decks/new)
//   '새 덱' FAB에서 진입. 이름·아이콘·설명·상위 덱 입력.
//   AppShell 내부 BODY 화면(별도 Scaffold 없음).
// ═══════════════════════════════════════════════════════════════════════════

class DeckCreateScreen extends ConsumerStatefulWidget {
  const DeckCreateScreen({super.key});

  @override
  ConsumerState<DeckCreateScreen> createState() => _DeckCreateScreenState();
}

class _DeckCreateScreenState extends ConsumerState<DeckCreateScreen> {
  static const List<String> _emojiChoices = [
    '📚',
    '🧠',
    '💡',
    '🎯',
    '🧮',
    '🌐',
    '🔬',
    '💻',
    '📝',
    '🎨',
    '🗂️',
    '⚙️',
  ];

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _emoji = _emojiChoices.first;
  String? _parentDeckId; // null = 최상위 덱

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('덱 만들기', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xl),

                // 덱 이름
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '덱 이름',
                    hintText: '예: 알고리즘 기초',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  // TODO: 팀원 구현 — 덱 이름 입력
                ),
                const SizedBox(height: AppSpacing.md),

                // 아이콘(이모지) 선택
                Text('아이콘', style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final e in _emojiChoices)
                      _EmojiChoice(
                        emoji: e,
                        selected: e == _emoji,
                        onTap: () => setState(() => _emoji = e),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 설명(선택)
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '설명 (선택)',
                    hintText: '이 덱에 대해 간단히 설명해주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  // TODO: 팀원 구현 — 덱 설명 입력
                ),
                const SizedBox(height: AppSpacing.md),

                // 상위 덱(선택)
                DropdownButtonFormField<String?>(
                  initialValue: _parentDeckId,
                  decoration: InputDecoration(
                    labelText: '상위 덱 (선택)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(child: Text('최상위 덱')),
                    for (final deck in _mockDecks)
                      DropdownMenuItem<String?>(
                        value: deck.id,
                        child: Text('${deck.emoji}  ${deck.name}'),
                      ),
                  ],
                  onChanged: (v) => setState(() => _parentDeckId = v),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 액션
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.decks),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // TODO: 팀원 구현 — learning-svc 덱 생성 API 연동
                          context.go(AppRoutes.decks);
                        },
                        child: const Text('만들기'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 덱 아이콘(이모지) 선택 칩.
class _EmojiChoice extends StatelessWidget {
  const _EmojiChoice({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
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
                  child: Text(deck.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    deck.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 덱 설명(생성 시 입력한 설명 표시)
            if (deck.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                deck.description,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  '하위 덱',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                children: [
                  _SubDeckTile(
                    name: '${deck.name} - 기본',
                    count: deck.cardCount ~/ 2,
                  ),
                  _SubDeckTile(
                    name: '${deck.name} - 심화',
                    count: deck.cardCount - deck.cardCount ~/ 2,
                  ),
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
      leading: const Icon(
        Icons.folder_outlined,
        size: 18,
        color: AppColors.muted,
      ),
      title: Text(name, style: textTheme.bodySmall),
      trailing: Text(
        '$count장',
        style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
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
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
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

    return Stack(
      children: [
        ConceptPage(
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
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
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
                            Text(
                              entry.value['front']!,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              entry.value['back']!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.muted,
                          size: 20,
                        ),
                        onPressed: () => context.go(AppRoutes.cardNew),
                        // TODO: 팀원 구현 — 카드 편집 화면 연동
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xxl),
          ],
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI 카드 생성(보조)
              FloatingActionButton.extended(
                heroTag: 'aiCardFab',
                onPressed: () => context.go(AppRoutes.aiCards),
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI 생성'),
              ),
              const SizedBox(height: AppSpacing.sm),
              // 직접 카드 작성(주)
              FloatingActionButton.extended(
                heroTag: 'newCardFab',
                onPressed: () =>
                    context.go(AppRoutes.deckCardNewPath(widget.deckId)),
                icon: const Icon(Icons.add),
                label: const Text('새 카드'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── CardEditorScreen (SCR-W-CARD-003) ──

class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({this.deckId, super.key});

  /// 카드를 추가할 덱 id. null이면 폼에서 덱을 직접 선택.
  final String? deckId;

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  String _cardType = 'basic';
  late String _selectedDeck;
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    // 진입한 덱이 있으면 그 덱으로 고정, 없으면 첫 덱 기본 선택.
    final id = widget.deckId;
    _selectedDeck = id == null
        ? _mockDecks.first.name
        : _mockDecks
              .firstWhere((d) => d.id == id, orElse: () => _mockDecks.first)
              .name;
  }

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
          items: [
            for (final d in _mockDecks)
              DropdownMenuItem(value: d.name, child: Text(d.name)),
          ],
          onChanged: (v) => setState(() {
            if (v != null) _selectedDeck = v;
          }),
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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: AppColors.muted,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '이미지 추가',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () {
            // TODO: 팀원 구현 — learning-svc 카드 저장 API 연동
            final id = widget.deckId;
            context.go(
              id != null ? AppRoutes.deckCardsPath(id) : AppRoutes.decks,
            );
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
  // v1 목업 ⑤: 대화 흐름 속에서 카드가 만들어진다.
  // 생성된 4장 중 기본 3장 선택(마지막 1장 미선택) — 목업과 동일.
  final Set<int> _selected = {0, 1, 2};

  static const _deckName = 'ML 기초';
  static const _xpPerCard = 5;

  // TODO: 팀원 구현 — learning-svc AI 카드 생성 API 연동(대화형)
  static const _generated = <_GenCard>[
    _GenCard(
      type: 'basic',
      q: '트랜스포머의 핵심 메커니즘은?',
      a: '어텐션 메커니즘 — 입력의 어느 부분에 집중할지 학습',
    ),
    _GenCard(type: 'cloze', q: '트랜스포머는 ___ 방지를 위해 드롭아웃을 쓴다', a: '과적합'),
    _GenCard(type: 'basic', q: '트랜스포머가 표준인 분야는?', a: 'NLP와 Vision'),
    _GenCard(type: 'basic', q: '어텐션과 RNN의 차이는?', a: '병렬 처리 가능, 장거리 의존성에 강함'),
  ];

  void _toggle(int i) {
    setState(() {
      if (!_selected.add(i)) _selected.remove(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = _selected.length;

    return Column(
      children: [
        // 대화 헤더 (orb + 이름 + ●답변 중)
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
        // 대화 본문
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  const ConceptChatBubble(
                    text: '트랜스포머 노트로 복습 카드 만들어줘',
                    isMe: true,
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  const ConceptChatBubble(
                    text: '「트랜스포머」 노트에서 핵심 4장을 만들었어요. 추가할 카드를 골라주세요 👇',
                    isMe: false,
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  for (int i = 0; i < _generated.length; i++)
                    _GenCardTile(
                      card: _generated[i],
                      checked: _selected.contains(i),
                      onChanged: (_) => _toggle(i),
                    ),
                ],
              ),
            ),
          ),
        ),
        // "N장 선택됨 · 덱 · +XP / 덱에 추가" 바
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: ConceptCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md - 2,
                  vertical: AppSpacing.sm + 2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$count장 선택됨',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '덱: $_deckName · +${count * _xpPerCard} XP',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: count > 0
                          ? () {
                              // TODO: 팀원 구현 — 선택 카드 덱 추가 API 연동
                              context.go(AppRoutes.decks);
                            }
                          : null,
                      child: const Text('덱에 추가'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 채팅 입력 바
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '더 물어보거나 카드를 수정하세요…',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: () {
                  // TODO: 팀원 구현 — 대화형 카드 수정 입력 연동
                },
                icon: const Icon(Icons.arrow_forward),
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
}

/// AI 생성 카드 1건 (v1 `.gencard`).
class _GenCard {
  const _GenCard({required this.type, required this.q, required this.a});
  final String type; // basic | cloze
  final String q;
  final String a;
}

/// 체크박스 + basic/cloze 배지 + Q/A. v1 목업 `.gencard`.
class _GenCardTile extends StatelessWidget {
  const _GenCardTile({
    required this.card,
    required this.checked,
    required this.onChanged,
  });

  final _GenCard card;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ConceptCard(
        highlightBorder: checked,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: checked,
                onChanged: onChanged,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardTypeBadge(card.type),
                  const SizedBox(height: AppSpacing.xs + 1),
                  Text(
                    'Q. ${card.q}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'A. ${card.a}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// basic / cloze 배지 (v1 `.gencard .badge`).
class _CardTypeBadge extends StatelessWidget {
  const _CardTypeBadge(this.type);
  final String type;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm - 6),
      ),
      child: Text(
        type,
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── ReviewScreen (FlipCard) ──

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  // v1 ⑥: 진행 7/18, 단계별 AI 힌트(1→2단계).
  static const _current = 7;
  static const _total = 18;

  // 진행바·카드·평점 버튼을 동일 폭으로 중앙 정렬(웹 넓은 폭에서 정렬 흐트러짐 방지).
  static const double _cardMaxWidth = 480;

  // TODO: 팀원 구현 — learning-svc 단계별 AI 힌트 API 연동
  static const _hints = [
    '힌트: 모델이 학습 데이터를 "외워버린" 상황을 떠올려 보세요. 새로운 데이터에서는 어떻게 될까요?',
    '힌트 2: 학습 데이터의 정답률은 매우 높지만, 처음 보는 검증 데이터에서는 정답률이 떨어지는 현상이에요.',
  ];

  int _hintLevel = 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Progress row — 카드와 동일 폭(480)으로 중앙 정렬
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _cardMaxWidth + AppSpacing.lg * 2,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
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
                        value: _current / _total,
                        minHeight: 7,
                        backgroundColor: AppColors.surface2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '$_current / $_total',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Card area
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 260,
                      child: FlipCard(
                        front: _FlashFace(
                          label: '과적합이란 무엇인가?',
                          hint: '👆 탭하여 정답 확인',
                        ),
                        back: _FlashFace(
                          label: '학습 데이터에는 잘 맞지만 새 데이터에 일반화하지 못하는 현상.',
                          highlighted: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // 단계별 AI 힌트
                    for (int i = 0; i < _hintLevel; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      ConceptAiComment(text: _hints[i]),
                    ],
                    if (_hintLevel < _hints.length) ...[
                      const SizedBox(height: AppSpacing.md),
                      _HintButton(onTap: () => setState(() => _hintLevel++)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Difficulty buttons (SM-2 rating) — 카드와 동일 폭(480)으로 중앙 정렬
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _cardMaxWidth + AppSpacing.lg * 2,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  _RateButton(
                    label: '다시',
                    sub: '<1분',
                    color: AppColors.error,
                    onTap: () {
                      // TODO: 팀원 구현 — SM-2 rating API 호출
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '어려움',
                    sub: '4일',
                    color: AppColors.warning,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '보통',
                    sub: '9일',
                    color: AppColors.success,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RateButton(
                    label: '쉬움',
                    sub: '21일',
                    color: AppColors.accent,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlashFace extends StatelessWidget {
  const _FlashFace({required this.label, this.hint, this.highlighted = false});

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
            Text(
              label,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            // TODO: 팀원 구현 — learning-svc 카드 데이터 연동
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                hint!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
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
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "💡 한 단계 더 힌트 받기" 버튼. v1 목업 `.hintbtn` — surface2 배경 +
/// primary 점선 보더 + primary 텍스트.
class _HintButton extends StatelessWidget {
  const _HintButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: DottedBorderBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 3),
            child: Center(
              child: Text(
                '💡 한 단계 더 힌트 받기',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// primary 점선 테두리 박스 (CustomPaint). Flutter 기본 Border는 점선을
/// 지원하지 않으므로 직접 그린다.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.primary,
        radius: AppRadius.sm,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
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
          child: SynapseOrb(
            size: 84,
            glyph: '🎉',
            glyphScale: 0.48,
            shadow: true,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            '복습 완료!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            '오늘 25장을 모두 끝냈어요',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
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
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '14일',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.streak,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '연속 학습 중!',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
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
          text:
              '정답률이 지난주보다 6%p 올랐어요! 다만 「과적합」 관련 카드에서 막혔으니, 내일은 그 노트를 한 번 더 보면 좋겠어요. 🙌',
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
                child: Text(
                  '78%',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
                  leading: const Icon(
                    Icons.schedule,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  title: Text(
                    _kNextReviews[i]['title']!,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    _kNextReviews[i]['date']!,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
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
