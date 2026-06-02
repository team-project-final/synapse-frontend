part of '../concept.dart';

/// 둥근 pill 검색 바 (탭하면 콜백). 목업 `.searchbar`.
class ConceptSearchBar extends StatelessWidget {
  const ConceptSearchBar({
    required this.hint,
    this.value,
    this.onTap,
    super.key,
  });

  final String hint;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final has = value != null && value!.isNotEmpty;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.muted),
              const SizedBox(width: AppSpacing.sm + 1),
              Expanded(
                child: Text(
                  has ? value! : hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: has ? AppColors.text : AppColors.muted,
                    fontWeight: has ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 이모지 아이콘 선택기 — 후보 이모지를 타일로 보여주고 선택 항목을 강조한다.
/// 덱/그룹 생성 등에서 아이콘을 고를 때 공통으로 사용.
class ConceptEmojiPicker extends StatelessWidget {
  const ConceptEmojiPicker({
    required this.emojis,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> emojis;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final e in emojis)
          _ConceptEmojiTile(
            emoji: e,
            selected: e == selected,
            onTap: () => onSelected(e),
          ),
      ],
    );
  }
}

class _ConceptEmojiTile extends StatelessWidget {
  const _ConceptEmojiTile({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
