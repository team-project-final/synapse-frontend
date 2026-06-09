part of '../card_screens.dart';

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
  String _cardType = 'BASIC';
  String? _selectedDeckId;
  bool _isSubmitting = false;
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _selectedDeckId = widget.deckId;
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

  Future<void> _save(List<Deck> decks) async {
    final deckId = _selectedDeckId ?? (decks.isNotEmpty ? decks.first.id : null);
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    if (deckId == null || front.isEmpty || back.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(createCardUseCaseProvider).call(
            deckId,
            frontContent: front,
            backContent: back,
            cardType: _cardType,
          );
      ref.invalidate(cardListProvider(deckId));
      if (mounted) {
        context.go(AppRoutes.deckCardsPath(deckId));
      }
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decks = ref.watch(deckListNotifierProvider).asData?.value ?? [];
    if (_selectedDeckId == null && decks.isNotEmpty) {
      _selectedDeckId = widget.deckId ?? decks.first.id;
    }

    return ConceptPage(
      children: [
        const ConceptViewHead(title: '카드 생성'),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'BASIC', label: Text('Basic')),
            ButtonSegment(value: 'CLOZE', label: Text('Cloze')),
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
        ),
        const SizedBox(height: AppSpacing.md),
        if (decks.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: _selectedDeckId,
            decoration: InputDecoration(
              labelText: '덱 선택',
              filled: true,
              fillColor: AppColors.surface,
              border: _inputBorder,
              enabledBorder: _inputBorder,
            ),
            items: [
              for (final d in decks)
                DropdownMenuItem(value: d.id, child: Text(d.name)),
            ],
            onChanged: (v) => setState(() {
              if (v != null) _selectedDeckId = v;
            }),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: _isSubmitting ? null : () => _save(decks),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('저장'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
