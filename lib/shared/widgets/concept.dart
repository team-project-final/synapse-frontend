import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/shared/widgets/synapse_orb.dart';

/// "AI Tutor" 컨셉의 재사용 디자인 컴포넌트 모음.
///
/// 대시보드(레퍼런스)에서 확립한 스타일(보라/핑크, 큰 radius, pill 칩, orb,
/// 그라데이션 suggest 카드 등)을 화면 전반에서 일관되게 쓰기 위해 한곳에 모은다.
/// 모든 색은 [AppColors]/[Theme] 토큰 경유 — hex 하드코딩 금지.

/// 섹션 구분 라벨 (대문자 muted, letterSpacing). 대시보드 `_SectionLabel`과 동일.
class ConceptSectionLabel extends StatelessWidget {
  const ConceptSectionLabel(
    this.label, {
    this.topGap = AppSpacing.xl,
    super.key,
  });

  final String label;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, topGap, 2, AppSpacing.sm + 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 보조 화면 상단의 뒤로가기 행. 모바일에서 셸 없이 화면이 뜰 때 사용.
class ConceptBackRow extends StatelessWidget {
  const ConceptBackRow({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.chevron_left, size: 20),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.muted,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

/// 뷰 제목 + 우측 메타. 목업 `.viewhead`.
class ConceptViewHead extends StatelessWidget {
  const ConceptViewHead({required this.title, this.meta, super.key});

  final String title;
  final String? meta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, AppSpacing.xs, 2, AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (meta != null)
            Text(
              meta!,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

/// 컨셉 표면 카드 — surface 배경 + border + 큰 radius. 탭 가능 옵션.
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

/// 그라데이션(보라→핑크) suggest/AI 카드. 대시보드 `_SuggestCard` 스타일.
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

/// 작은 태그 칩 — primary 틴트 배경. 목업 `.tag`.
class ConceptTag extends StatelessWidget {
  const ConceptTag(this.label, {this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 1,
        vertical: AppSpacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 선택 가능한 필터 pill (목업 `.tg`). 선택 시 primary 채움.
class ConceptFilterPill extends StatelessWidget {
  const ConceptFilterPill({
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
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md - 2,
            vertical: AppSpacing.sm - 1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
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

/// 한 줄 채팅 말풍선. 대시보드 `_ChatBubble`과 동일 스타일.
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
              letterSpacing: -0.5,
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

/// 넓으면 N열, 좁으면 1열. 대시보드 `_ResponsiveTwoCol` 일반화.
class ConceptResponsiveGrid extends StatelessWidget {
  const ConceptResponsiveGrid({
    required this.isWide,
    required this.children,
    this.gap = AppSpacing.sm + 2,
    this.minColumnWidth = 280,
    super.key,
  });

  final bool isWide;
  final List<Widget> children;
  final double gap;

  /// 한 열의 최소 폭. 가용 폭을 이 값으로 나눠 열 수를 정한다.
  /// (예전엔 wide면 항목 전부를 한 행에 균등 배치 → 중간 폭에서 카드가
  /// 과도하게 좁아져 헤더 정렬이 깨졌다. 최소 폭을 보장하며 줄바꿈한다.)
  final double minColumnWidth;

  Widget _singleColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isWide) return _singleColumn();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int byWidth = (constraints.maxWidth / minColumnWidth).floor();
        final int columns = byWidth < 1
            ? 1
            : (byWidth > children.length ? children.length : byWidth);

        if (columns <= 1) return _singleColumn();

        final List<Widget> rows = [];
        for (int i = 0; i < children.length; i += columns) {
          final List<Widget> cells = [];
          for (int j = 0; j < columns; j++) {
            if (j > 0) cells.add(SizedBox(width: gap));
            final int idx = i + j;
            cells.add(
              Expanded(
                child: idx < children.length
                    ? children[idx]
                    : const SizedBox.shrink(), // 마지막 행 빈 칸(카드 폭 유지)
              ),
            );
          }
          if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
          // 세로 스크롤 안 Row(stretch)는 unbounded height 크래시 → IntrinsicHeight.
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cells,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
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

/// 화면 본문을 중앙 정렬 + 최대폭 제한으로 감싸는 헬퍼.
/// 데스크탑에서 콘텐츠가 과도하게 늘어지지 않게 한다.
class ConceptPage extends StatelessWidget {
  const ConceptPage({
    required this.children,
    this.maxWidth = 760,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.lg,
    ),
    super.key,
  });

  final List<Widget> children;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
