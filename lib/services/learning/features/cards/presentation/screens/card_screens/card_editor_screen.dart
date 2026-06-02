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
