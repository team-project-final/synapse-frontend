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
