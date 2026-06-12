part of '../kanban_section.dart';

class KanbanSection extends StatelessWidget {
  const KanbanSection({this.scrollable = true, this.date, super.key});

  // false면 외부(세로) ListView가 자체 스크롤하지 않고 외부 스크롤 뷰가
  // 담당한다(임베드 모드). 내부 _MobileBoard 가로 스크롤은 영향받지 않는다.
  final bool scrollable;

  // 플래너에서 선택된 날짜. 지정되면 보드 헤더에 해당 날짜를 표시한다.
  // TODO: 팀원 구현 — learning-svc 연동 시 이 날짜의 카드만 로드한다.
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 600;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        // 모바일에서 보드는 화면 끝까지 가로 스크롤되므로
        // 가로 패딩을 보드가 직접 관리한다.
        isMobile ? 0 : AppSpacing.lg,
        AppSpacing.md,
      ),
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      children: <Widget>[
        // ── 헤더 ──
        // 날짜 지정(플래너) 시 날짜 헤더, 아니면 모바일 전용 기본 헤더.
        if (date != null) ...<Widget>[
          Padding(
            padding: EdgeInsets.only(right: isMobile ? AppSpacing.lg : 0),
            child: _DateBoardHeader(date: date!),
          ),
          const SizedBox(height: AppSpacing.md),
        ] else if (isMobile) ...<Widget>[
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: _BoardHeader(),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── 오늘 진행 요약 바 ──
        Padding(
          padding: EdgeInsets.only(right: isMobile ? AppSpacing.lg : 0),
          child: const _ProgressLine(),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── 칸반 보드 ──
        if (isMobile)
          const _MobileBoard(columns: _kBoardColumns)
        else
          const _DesktopBoard(columns: _kBoardColumns),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ── 모바일 헤더 ──────────────────────────────────────────────────────────────

class _BoardHeader extends StatelessWidget {
  const _BoardHeader();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('내 학습 보드', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '화요일 · 오늘 복습 18장 대기',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          icon: Icons.add,
          onTap: () => context.go(_kComposeRoute),
        ),
      ],
    );
  }
}

/// 한국어 요일(월~일). DateTime.weekday: 월=1 … 일=7.
String _weekdayKo(DateTime d) =>
    const <String>['월', '화', '수', '목', '금', '토', '일'][d.weekday - 1];

/// 플래너에서 선택한 날짜의 보드 헤더(날짜 + 추가 버튼).
class _DateBoardHeader extends StatelessWidget {
  const _DateBoardHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${date.year}년 ${date.month}월 ${date.day}일 (${_weekdayKo(date)}) 보드',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '선택한 날짜의 학습 보드 · 복습 18장 대기',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 19, color: AppColors.text),
        ),
      ),
    );
  }
}

// ── 진행 요약 바 (progline) ──────────────────────────────────────────────────

class _ProgressLine extends StatelessWidget {
  const _ProgressLine();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '오늘 진행',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('38장 중 12 완료', style: textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 세그먼트 진행 바: 학습/복습/완료
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: const SizedBox(
                height: 10,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 18,
                      child: ColoredBox(color: AppColors.primary),
                    ),
                    Expanded(
                      flex: 30,
                      child: ColoredBox(color: AppColors.streak),
                    ),
                    Expanded(
                      flex: 32,
                      child: ColoredBox(color: AppColors.success),
                    ),
                    Expanded(
                      flex: 20,
                      child: ColoredBox(color: AppColors.surface2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Wrap(
              spacing: AppSpacing.md,
              children: <Widget>[
                _Legend(color: AppColors.primary, label: '학습'),
                _Legend(color: AppColors.streak, label: '복습'),
                _Legend(color: AppColors.success, label: '완료'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

// ── 데스크탑 보드: 4컬럼 그리드 ──────────────────────────────────────────────

class _DesktopBoard extends StatelessWidget {
  const _DesktopBoard({required this.columns});

  final List<_KanbanColumn> columns;

  // 컬럼 최소 폭. 가용 폭이 이보다 좁아지면 컬럼을 찌그러뜨리지 않고
  // 가로 스크롤로 전환한다(웹↔모바일 사이 애매한 폭에서 찌그러짐 방지).
  static const double _minColWidth = 250;
  static const double _gap = AppSpacing.sm + AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int n = columns.length;
        final double needed = n * _minColWidth + (n - 1) * _gap;
        final bool fits = constraints.maxWidth >= needed;

        final Widget row = IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < n; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: _gap),
                // 충분하면 Expanded로 꽉 채우고, 부족하면 최소 폭 고정.
                if (fits)
                  Expanded(child: _BoardColumn(column: columns[i]))
                else
                  SizedBox(
                    width: _minColWidth,
                    child: _BoardColumn(column: columns[i]),
                  ),
              ],
            ],
          ),
        );

        if (fits) return row;
        // 폭 부족 → 가로 스크롤(마우스 드래그 포함, 앱 전역 scrollBehavior).
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: row,
        );
      },
    );
  }
}

// ── 모바일 보드: 가로 스크롤 ──────────────────────────────────────────────────

class _MobileBoard extends StatelessWidget {
  const _MobileBoard({required this.columns});

  final List<_KanbanColumn> columns;

  @override
  Widget build(BuildContext context) {
    final double colWidth = MediaQuery.sizeOf(context).width * 0.84;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      physics: const ClampingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < columns.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
            SizedBox(
              width: colWidth,
              child: _BoardColumn(column: columns[i]),
            ),
            if (i == columns.length - 1) const SizedBox(width: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

// ── 칸반 컬럼 ────────────────────────────────────────────────────────────────

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({required this.column});

  final _KanbanColumn column;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 컬럼 상단 색 스트립
          Container(height: 4, color: column.stripColor),
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(column.title, style: textTheme.titleSmall),
                ),
                _WipBadge(count: column.wip),
              ],
            ),
          ),
          // 카드들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < column.cards.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _KanbanCardTile(card: column.cards[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
