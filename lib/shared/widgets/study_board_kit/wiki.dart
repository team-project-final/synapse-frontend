part of '../study_board_kit.dart';

/// 목업 `.wl` — 본문 안의 위키링크([[..]]) 칩.
/// primary 10% 틴트 + radius 5 인라인 배경.
class WikiLinkChip extends StatelessWidget {
  const WikiLinkChip({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14.5,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}

/// 목업 `.body-txt` — `[[위키링크]]` 를 [WikiLinkChip] 으로 인라인 렌더하는 본문.
/// 마크다운 대신 위키링크를 강조하고 싶은 노트 본문에 사용.
class WikiText extends StatelessWidget {
  const WikiText({required this.text, this.onLinkTap, super.key});

  final String text;

  /// 링크 라벨(괄호 제외)로 콜백.
  final ValueChanged<String>? onLinkTap;

  static final _linkPattern = RegExp(r'\[\[(.+?)\]\]');

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontSize: 14.5,
      height: 1.75,
      color: AppColors.text,
    );
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _linkPattern.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      final label = m.group(1)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: WikiLinkChip(
            label: label,
            onTap: onLinkTap == null ? null : () => onLinkTap!(label),
          ),
        ),
      );
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }
}

/// 목업 `.backlinks .bl` — 백링크/참조 노트 한 줄(제목 + 스니펫 + ↗).
class BacklinkRow extends StatelessWidget {
  const BacklinkRow({
    required this.title,
    required this.onTap,
    this.snippet,
    this.showDivider = true,
    super.key,
  });

  final String title;
  final String? snippet;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              )
            : null,
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (snippet != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      snippet!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              '↗',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// 그래프 범례 한 항목(태그 색 점 + 라벨).
class GraphLegendItem {
  const GraphLegendItem({required this.label, required this.color});
  final String label;
  final Color color;
}

/// 목업 `.glegend` — 그래프 태그-색 범례(Wrap).
class GraphLegend extends StatelessWidget {
  const GraphLegend({required this.items, super.key});

  final List<GraphLegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final it in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: it.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                it.label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
