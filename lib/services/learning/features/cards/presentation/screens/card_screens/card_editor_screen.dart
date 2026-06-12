part of '../card_screens.dart';

// ── CardEditorScreen (SCR-W-CARD-003) ──

class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({this.deckId, this.cardId, super.key});

  /// 카드를 추가할 덱 id. null이면 폼에서 덱을 직접 선택.
  final String? deckId;

  /// 편집할 카드 id. null이면 신규 생성, 값이 있으면 편집 모드.
  final String? cardId;

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  String _cardType = 'BASIC';
  String? _selectedDeckId;
  bool _isSubmitting = false;
  bool _initialized = false;
  bool get _isEditMode => widget.cardId != null;

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
    if (_isSubmitting) return;
    if (deckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('덱을 선택해주세요')));
      return;
    }
    if (front.isEmpty || back.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('앞면과 뒷면을 입력해주세요')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      if (_isEditMode) {
        await ref.read(updateCardUseCaseProvider).call(
              deckId,
              widget.cardId!,
              frontContent: front,
              backContent: back,
              cardType: _cardType,
            );
      } else {
        await ref.read(createCardUseCaseProvider).call(
              deckId,
              frontContent: front,
              backContent: back,
              cardType: _cardType,
            );
      }
      ref.invalidate(cardListProvider(deckId));
      ref.invalidate(reviewQueueCountProvider(deckId));
      if (mounted) {
        context.go(AppRoutes.deckCardsPath(deckId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decks = ref.watch(deckListNotifierProvider).asData?.value ?? [];
    if (_selectedDeckId == null && decks.isNotEmpty) {
      _selectedDeckId = widget.deckId ?? decks.first.id;
    }

    // 편집 모드: 카드 목록 캐시에서 기존 값 초기화
    if (_isEditMode && !_initialized && widget.deckId != null) {
      final card = ref
          .watch(cardListProvider(widget.deckId!))
          .asData
          ?.value
          .where((c) => c.id == widget.cardId)
          .firstOrNull;
      if (card != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _frontController.text = card.frontContent;
              _backController.text = card.backContent;
              _cardType = card.cardType;
              _initialized = true;
            });
          }
        });
      }
    }

    return ConceptPage(
      children: [
        ConceptViewHead(title: _isEditMode ? '카드 수정' : '카드 생성'),
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
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: _isSubmitting ? null : () => _save(decks),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditMode ? '수정 완료' : '저장'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
