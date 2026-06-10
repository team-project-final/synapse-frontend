part of '../card_screens.dart';

// ── AiCardGenerationScreen (SCR-W-CARD-004) ──

class AiCardGenerationScreen extends ConsumerStatefulWidget {
  const AiCardGenerationScreen({super.key});

  @override
  ConsumerState<AiCardGenerationScreen> createState() =>
      _AiCardGenerationScreenState();
}

class _AiCardGenerationScreenState
    extends ConsumerState<AiCardGenerationScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  // 선택된 카드 인덱스 (AiCardsMsg 기준 — 메시지별 독립 관리)
  final Map<int, Set<int>> _selectedByMsgIndex = {};

  static const _xpPerCard = 5;
  String? _selectedDeckId;
  bool _isAdding = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _addCardsToDeck(List<Deck> decks) async {
    final deckId = _selectedDeckId ?? (decks.isNotEmpty ? decks.first.id : null);
    if (deckId == null || _isAdding) return;

    final cards = <Map<String, String>>[];
    final conv = ref.read(cardGenNotifierProvider).conversation;
    for (int i = 0; i < conv.length; i++) {
      if (conv[i] is! AiCardsMsg) continue;
      final aiCards = (conv[i] as AiCardsMsg).cards;
      final selectedIndices = _selectedByMsgIndex[i] ??
          Set<int>.from(Iterable<int>.generate(aiCards.length));
      for (final idx in selectedIndices) {
        if (idx < aiCards.length) {
          cards.add({
            'frontContent': aiCards[idx].front,
            'backContent': aiCards[idx].back,
            'cardType': 'BASIC',
          });
        }
      }
    }
    if (cards.isEmpty) return;
    setState(() => _isAdding = true);
    try {
      await ref.read(batchCreateCardsUseCaseProvider).call(deckId, cards);
      ref.invalidate(cardListProvider(deckId));
      if (mounted) context.go(AppRoutes.decks);
    } catch (_) {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(cardGenNotifierProvider.notifier).generate(
          input: text,
          cardCount: 10,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardGenState = ref.watch(cardGenNotifierProvider);
    final decks = ref.watch(deckListNotifierProvider).asData?.value ?? [];
    final deckName = _selectedDeckId != null
        ? decks.firstWhere((d) => d.id == _selectedDeckId, orElse: () => decks.first).name
        : (decks.isNotEmpty ? decks.first.name : '덱 없음');

    ref.listen(cardGenNotifierProvider, (_, __) => _scrollToBottom());

    // 선택 카드 총 개수 계산 — 맵에 없는 AiCardsMsg는 전체 선택으로 간주
    int selectedCount = 0;
    for (int i = 0; i < cardGenState.conversation.length; i++) {
      final item = cardGenState.conversation[i];
      if (item is AiCardsMsg) {
        final s = _selectedByMsgIndex[i] ??
            Set<int>.from(Iterable<int>.generate(item.cards.length));
        selectedCount += s.length;
      }
    }

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
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    cardGenState.isLoading ? '● 생성 중' : '● 대기 중',
                    style: textTheme.labelSmall?.copyWith(
                      color: cardGenState.isLoading
                          ? AppColors.warning
                          : AppColors.success,
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
              child: cardGenState.conversation.isEmpty
                  ? Center(
                      child: Text(
                        '노트 내용을 붙여넣거나 질문하면\nAI가 플래시카드를 만들어드립니다',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: cardGenState.conversation.length,
                      itemBuilder: (context, index) {
                        final item = cardGenState.conversation[index];
                        return switch (item) {
                          AiTextMsg(:final isUser, :final text) =>
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: ConceptChatBubble(
                                  text: text, isMe: isUser),
                            ),
                          AiLoadingMsg() => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text('카드 생성 중…',
                                      style: textTheme.labelSmall
                                          ?.copyWith(color: AppColors.muted)),
                                ],
                              ),
                            ),
                          AiErrorMsg(:final message) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: ConceptChatBubble(
                                  text: '⚠️ $message', isMe: false),
                            ),
                          AiCardsMsg(:final cards) => _CardResultBlock(
                              msgIndex: index,
                              cards: cards,
                              selected: _selectedByMsgIndex[index] ??
                                  Set.from(
                                    Iterable.generate(cards.length),
                                  ),
                              onToggle: (cardIdx) => setState(() {
                                final s = _selectedByMsgIndex[index] ??
                                    Set.from(
                                      Iterable.generate(cards.length),
                                    );
                                if (!s.remove(cardIdx)) s.add(cardIdx);
                                _selectedByMsgIndex[index] = s;
                              }),
                            ),
                        };
                      },
                    ),
            ),
          ),
        ),

        // 선택 카드 → 덱 추가 바 (카드가 하나라도 선택됐을 때)
        if (selectedCount > 0)
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
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
                              '$selectedCount장 선택됨',
                              style: textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '덱: $deckName · +${selectedCount * _xpPerCard} XP',
                              style: textTheme.labelSmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: _isAdding ? null : () => _addCardsToDeck(decks),
                        child: _isAdding
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('덱에 추가'),
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
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  enabled: !cardGenState.isLoading,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '노트 내용을 붙여넣거나 카드 생성을 요청하세요…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    filled: true,
                    fillColor: AppColors.surface2,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: cardGenState.isLoading ? null : _send,
                icon: cardGenState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.arrow_upward),
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

// ── 카드 결과 블록 ──

class _CardResultBlock extends StatelessWidget {
  const _CardResultBlock({
    required this.msgIndex,
    required this.cards,
    required this.selected,
    required this.onToggle,
  });

  final int msgIndex;
  final List<GeneratedCard> cards;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: cards.asMap().entries.map((e) {
        final i = e.key;
        final card = e.value;
        final checked = selected.contains(i);
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
                    onChanged: (_) => onToggle(i),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q. ${card.front}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'A. ${card.back}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      }).toList(),
    );
  }
}
