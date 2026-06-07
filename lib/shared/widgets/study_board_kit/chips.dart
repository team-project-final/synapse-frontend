part of '../study_board_kit.dart';

/// 목업 `.tag` — primary 14% 틴트 스타디움 칩.
class StudyTag extends StatelessWidget {
  const StudyTag({required this.label, this.color, super.key});

  final String label;

  /// 기본 primary. 다른 색(accent/streak) 틴트도 허용.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

/// 목업 `.pill` — 필터 토글 칩.
class StudyPill extends StatelessWidget {
  const StudyPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface2,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primaryFg : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// 목업 `.sec-t` — 섹션 제목(대문자 트래킹 라벨).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: AppColors.muted,
      ),
    );
    if (trailing == null) return label;
    return Row(
      children: [
        Expanded(child: label),
        trailing!,
      ],
    );
  }
}
