part of '../study_board_kit.dart';

/// 목업 `.card` — 표면 카드(보더 + radius 12 패딩 컨테이너).
/// Theme 의 [Card] 와 동일 스타일이되 탭/패딩 제어가 필요할 때 사용.
class StudyCard extends StatelessWidget {
  const StudyCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.sm);
    final content = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(borderRadius: radius, onTap: onTap, child: content),
    );
  }
}

/// 목업 `.semantic` — accent 틴트 강조 배너(AI/의미 검색 등).
class SemanticBanner extends StatelessWidget {
  const SemanticBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tint,
    this.trailing,
    super.key,
  });

  /// 이모지 또는 짧은 글리프.
  final String icon;
  final String title;
  final String subtitle;

  /// 기본 accent. streak/success 등으로 의미 변경 가능.
  final Color? tint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = tint ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.withValues(alpha: 0.10), AppColors.surface),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: Color.alphaBlend(c.withValues(alpha: 0.30), AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: c,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

/// AI 생성 카드의 타입(basic/cloze) 배지 색을 한곳에서 관리.
enum GenCardType { basic, cloze }

extension GenCardTypeStyle on GenCardType {
  String get label => switch (this) {
    GenCardType.basic => 'BASIC',
    GenCardType.cloze => 'CLOZE',
  };
}

/// 목업 `.gencard` — AI 생성 카드(체크박스 + 타입 배지 + Q/A).
class GenCard extends StatelessWidget {
  const GenCard({
    required this.type,
    required this.question,
    required this.answer,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final GenCardType type;
  final String question;
  final String answer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudyCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .chk — 22x22 radius7 체크박스.
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 14, color: AppColors.primaryFg)
                : null,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 목업 `.badge` — 잠금 가능한 게이미피케이션 배지 한 칸.
class BadgeTile extends StatelessWidget {
  const BadgeTile({
    required this.emoji,
    required this.label,
    this.locked = false,
    super.key,
  });

  final String emoji;
  final String label;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                AppColors.primary.withValues(alpha: 0.12),
                AppColors.surface,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Opacity(
              opacity: locked ? 0.4 : 1,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}
