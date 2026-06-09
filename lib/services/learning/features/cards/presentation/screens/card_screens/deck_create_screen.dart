part of '../card_screens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DeckCreateScreen — 새 덱 생성 폼(/decks/new)
// ═══════════════════════════════════════════════════════════════════════════

class DeckCreateScreen extends ConsumerStatefulWidget {
  const DeckCreateScreen({super.key});

  @override
  ConsumerState<DeckCreateScreen> createState() => _DeckCreateScreenState();
}

class _DeckCreateScreenState extends ConsumerState<DeckCreateScreen> {
  static const List<String> _emojiChoices = [
    '📚', '🧠', '💡', '🎯', '🧮', '🌐', '🔬', '💻', '📝', '🎨', '🗂️', '⚙️',
  ];

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _emoji = _emojiChoices.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(deckListNotifierProvider.notifier).createDeck(
            name: name,
            description: _descController.text.trim(),
            color: _emoji,
          );
      if (mounted) context.go(AppRoutes.decks);
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                ),
                const SizedBox(height: AppSpacing.md),

                Text('아이콘', style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                ConceptEmojiPicker(
                  emojis: _emojiChoices,
                  selected: _emoji,
                  onSelected: (e) => setState(() => _emoji = e),
                ),
                const SizedBox(height: AppSpacing.md),

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
                ),
                const SizedBox(height: AppSpacing.xl),

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
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('만들기'),
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
