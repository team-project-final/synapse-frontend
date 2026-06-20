part of '../concept.dart';

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
                letterSpacing: 0,
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
    // Center > ConstrainedBox > ListView: 각 항목이 정상 sliver로 남아 lazy
    // 빌드/스크롤(scrollUntilVisible)·탭 히트테스트가 일반 ListView처럼 동작한다.
    // (예전엔 ListView의 단일 자식 Column으로 감싸 스크롤 후 탭이 빗나갔다.)
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(padding: padding, children: children),
      ),
    );
  }
}
