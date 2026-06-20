part of '../concept.dart';

/// 한 줄 채팅 말풍선. isMe로 좌/우 정렬과 색을 구분한다.
class ConceptChatBubble extends StatelessWidget {
  const ConceptChatBubble({required this.text, required this.isMe, super.key});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md - 2,
            vertical: AppSpacing.sm + 3,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.bg,
            border: isMe ? null : Border.all(color: AppColors.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 5),
              bottomRight: Radius.circular(isMe ? 5 : 16),
            ),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isMe ? AppColors.primaryFg : AppColors.text,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// orb 아바타 + AI 코멘트 말풍선. 목업 `.ai-comment`.
class ConceptAiComment extends StatelessWidget {
  const ConceptAiComment({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SynapseOrb(size: 32, glyphScale: 0.47),
        const SizedBox(width: AppSpacing.sm + 1),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md - 2,
              vertical: AppSpacing.sm + 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.text,
                height: 1.55,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 통계 셀 (값 + 라벨). 대시보드 `_InsightStat`과 동일 스타일.
class ConceptStat extends StatelessWidget {
  const ConceptStat({
    required this.value,
    required this.label,
    this.color = AppColors.text,
    super.key,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md - 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3열 stat 그리드. 자식이 [ConceptStat] 등일 때 균등 분배.
class ConceptStatRow extends StatelessWidget {
  const ConceptStatRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // 세로 스크롤(ListView) 안에서 Row(stretch)는 높이가 unbounded라
    // 단언 위반/크래시가 난다. IntrinsicHeight로 높이를 확정해 감싼다.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm + 2),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

/// 빈 상태 플레이스홀더 (아이콘/이모지 + 제목 + 설명 + 선택적 액션).
class ConceptEmptyState extends StatelessWidget {
  const ConceptEmptyState({
    required this.emoji,
    required this.title,
    this.body,
    this.action,
    super.key,
  });

  final String emoji;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface2,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}

/// AI에게 질문하기 진입 버튼. 목업 `.ai-entry` — orb + 제목/설명 + chevron.
class ConceptAiEntry extends StatelessWidget {
  const ConceptAiEntry({
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ConceptGradientCard(
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          child: Row(
            children: [
              const SynapseOrb(size: 32, glyphScale: 0.47),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
