part of '../card_screens.dart';

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
                ConceptEmojiPicker(
                  emojis: _emojiChoices,
                  selected: _emoji,
                  onSelected: (e) => setState(() => _emoji = e),
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
