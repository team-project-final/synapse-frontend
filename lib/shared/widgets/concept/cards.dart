part of '../concept.dart';

/// 컨셉 표면 카드 — surface 배경 + border + panel radius. 탭 가능 옵션.
class ConceptCard extends StatelessWidget {
  const ConceptCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.highlightBorder = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// primary 보더로 강조 (포커스/AI 박스 느낌).
  final bool highlightBorder;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: highlightBorder ? AppColors.primary : AppColors.border,
          width: highlightBorder ? 1.5 : 1,
        ),
      ),
      child: child,
    );
    if (onTap == null) return decorated;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: decorated,
      ),
    );
  }
}

/// Subtle suggest/AI card using restrained product tokens.
class ConceptGradientCard extends StatelessWidget {
  const ConceptGradientCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: child,
    );
  }
}
