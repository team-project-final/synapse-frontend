import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Study Board (컨셉 H) 공통 위젯 키트
//   목업의 재사용 컴포넌트(.tag/.pill/.searchbar/.sec-t/.ph/.semantic/.statgrid
//   등)를 Flutter 위젯으로 옮긴다. 모든 색은 AppColors / Theme 토큰만 사용한다.
//   디자인 전용 — 비즈니스 로직 없음.
// ═══════════════════════════════════════════════════════════════════════════

/// 학습 파이프라인 단계. 컬럼 스트립/페이즈 핀 색을 한 곳에서 관리.
enum BoardPhase { collect, learn, review, done }

extension BoardPhaseStyle on BoardPhase {
  String get label => switch (this) {
        BoardPhase.collect => '수집함',
        BoardPhase.learn => '학습 중',
        BoardPhase.review => '복습 대기',
        BoardPhase.done => '완료',
      };

  Color get color => switch (this) {
        BoardPhase.collect => AppColors.columnCollect,
        BoardPhase.learn => AppColors.columnLearn,
        BoardPhase.review => AppColors.columnReview,
        BoardPhase.done => AppColors.columnDone,
      };
}

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
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: c,
        ),
      ),
    );
  }
}

/// 목업 `.ph.*` — 학습 단계 핀(페이즈 배지).
class PhasePin extends StatelessWidget {
  const PhasePin({required this.phase, super.key});

  final BoardPhase phase;

  @override
  Widget build(BuildContext context) {
    final c = phase.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        phase.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: c,
        ),
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

/// 목업 `.searchbar` — 스타디움 검색 입력.
class StudySearchBar extends StatelessWidget {
  const StudySearchBar({
    required this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.muted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              autofocus: autofocus,
              onTap: onTap,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ],
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
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: content,
      ),
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

/// 목업 `.statgrid .s` — 3분할 통계 셀.
class StatCell {
  const StatCell({required this.value, required this.label, this.accent = false});
  final String value;
  final String label;
  final bool accent;
}

/// 목업 `.statgrid` — 균등 분할 통계 그리드.
class StatGrid extends StatelessWidget {
  const StatGrid({required this.cells, super.key});

  final List<StatCell> cells;

  @override
  Widget build(BuildContext context) {
    // stretch + 세로 비제한 컨텍스트(ListView)에서 무한 높이 강제를 피하려고
    // IntrinsicHeight 로 행 높이를 자식 최대 높이에 맞춰 제한한다.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < cells.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatCellView(cell: cells[i])),
          ],
        ],
      ),
    );
  }
}

class _StatCellView extends StatelessWidget {
  const _StatCellView({required this.cell});

  final StatCell cell;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm - 4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Text(
              cell.value,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: cell.accent ? AppColors.primary : AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            cell.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// 목업 `.xpbar` — primary→accent 그라데이션 진행 바.
class XpBar extends StatelessWidget {
  const XpBar({required this.progress, this.height = 9, super.key});

  /// 0.0 ~ 1.0.
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: AppColors.surface2,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clamped,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: WikiLinkChip(
          label: label,
          onTap: onLinkTap == null ? null : () => onLinkTap!(label),
        ),
      ));
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
                border:
                    Border(bottom: BorderSide(color: AppColors.border)),
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
            const Text('↗',
                style: TextStyle(fontSize: 14, color: AppColors.muted)),
          ],
        ),
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
                ? const Icon(Icons.check,
                    size: 14, color: AppColors.primaryFg)
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

/// 복습 SRS 평가 4버튼의 한 칸 사양.
class RateOption {
  const RateOption({
    required this.label,
    required this.interval,
    required this.color,
  });
  final String label;

  /// 다음 복습 간격(예: '<1분', '4일').
  final String interval;
  final Color color;
}

/// 목업 `.rate` — 복습 4단계 평가 버튼(라벨 + 간격).
/// 기본 4칸: 다시/어려움/보통/쉬움(danger/warning/success/accent).
class RateButtons extends StatelessWidget {
  const RateButtons({required this.onRate, this.options, super.key});

  /// 인덱스(0=다시 … 3=쉬움)로 콜백.
  final ValueChanged<int> onRate;
  final List<RateOption>? options;

  static const _defaults = [
    RateOption(label: '다시', interval: '<1분', color: AppColors.error),
    RateOption(label: '어려움', interval: '4일', color: AppColors.streak),
    RateOption(label: '보통', interval: '9일', color: AppColors.success),
    RateOption(label: '쉬움', interval: '21일', color: AppColors.accent),
  ];

  @override
  Widget build(BuildContext context) {
    final opts = options ?? _defaults;
    return Row(
      children: [
        for (var i = 0; i < opts.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Material(
              color: opts[i].color,
              borderRadius: BorderRadius.circular(AppRadius.sm - 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm - 8),
                onTap: () => onRate(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opts[i].label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        opts[i].interval,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
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
                  AppColors.surface),
              borderRadius: BorderRadius.circular(16),
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

/// 목업 `.iconbtn` — 원형 보더 아이콘 버튼.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: filled ? AppColors.primary : AppColors.surface,
      shape: CircleBorder(
        side: filled
            ? BorderSide.none
            : const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 19,
            color: filled ? AppColors.primaryFg : AppColors.text,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
