part of '../kanban_section.dart';

class KanbanSection extends ConsumerWidget {
  const KanbanSection({this.scrollable = true, required this.date, super.key});

  // false면 외부(세로) ListView가 자체 스크롤하지 않고 외부 스크롤 뷰가
  // 담당한다(임베드 모드). 내부 _MobileBoard 가로 스크롤은 영향받지 않는다.
  final bool scrollable;

  // 플래너에서 선택된 날짜. 보드 헤더에 해당 날짜를 표시하고 그 날짜의 덱
  // 요약을 조회하는 데 쓰인다. 호출처(PlannerSection)가 항상 넘겨준다 —
  // DateTime.now() 폴백을 두면 매 rebuild마다 새 family 키가 되어
  // /stats/decks 요청이 반복될 수 있다.
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 600;
    final AsyncValue<List<DeckSummary>> decksAsync = ref.watch(
      deckSummariesProvider(date),
    );

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
        // 헤더·진행 요약 바·보드 모두 덱 요약(decksAsync)에서 계산한 실제
        // 값을 쓰므로, 로딩/에러 상태와 어긋나지 않도록 전부 이 안에서
        // 함께 렌더한다.
        AppAsyncValueWidget<List<DeckSummary>>(
          value: decksAsync,
          data: (List<DeckSummary> decks) {
            final int dueTotal = decks.fold<int>(
              0,
              (int sum, DeckSummary d) => sum + d.dueCount,
            );
            final List<Widget> children = <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: isMobile ? AppSpacing.lg : 0,
                ),
                child: _DateBoardHeader(date: date, dueCount: dueTotal),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: EdgeInsets.only(
                  right: isMobile ? AppSpacing.lg : 0,
                ),
                child: _ProgressLine(decks: decks),
              ),
              const SizedBox(height: AppSpacing.md),
              if (decks.isEmpty)
                const AppEmptyState(
                  icon: Icons.style_outlined,
                  title: '아직 덱이 없습니다.',
                )
              else
                (isMobile
                    ? _MobileBoard(columns: _buildColumns(decks))
                    : _DesktopBoard(columns: _buildColumns(decks))),
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            );
          },
          error: (Object error, StackTrace stackTrace) => AppErrorWidget(
            message: '보드를 불러오지 못했습니다.',
            onRetry: () => ref.invalidate(deckSummariesProvider(date)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

/// 한국어 요일(월~일). DateTime.weekday: 월=1 … 일=7.
String _weekdayKo(DateTime d) =>
    const <String>['월', '화', '수', '목', '금', '토', '일'][d.weekday - 1];

/// 플래너에서 선택한 날짜의 보드 헤더(날짜 + 추가 버튼).
class _DateBoardHeader extends StatelessWidget {
  const _DateBoardHeader({required this.date, required this.dueCount});

  final DateTime date;
  final int dueCount;

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
                '선택한 날짜의 학습 보드 · 복습 $dueCount장 대기',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          icon: Icons.add,
          onTap: () => context.go(AppRoutes.noteEditorPath('new')),
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
  const _ProgressLine({required this.decks});

  final List<DeckSummary> decks;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // dueCount(복습 대기)와 reviewedCount(완료)만 실데이터로 신뢰할 수 있는
    // 수량이라 이 둘로만 계산한다. 원래 있던 "학습"(신규) 구간은 이 계산식이
    // 다루지 않는 값이라 표시하지 않는다.
    final int dueTotal = decks.fold<int>(
      0,
      (int sum, DeckSummary d) => sum + d.dueCount,
    );
    final int reviewedTotal = decks.fold<int>(
      0,
      (int sum, DeckSummary d) => sum + d.reviewedCount,
    );
    final int total = dueTotal + reviewedTotal;
    final List<Widget> segments = <Widget>[
      if (reviewedTotal > 0)
        Expanded(
          flex: reviewedTotal,
          child: const ColoredBox(color: AppColors.success),
        ),
      if (dueTotal > 0)
        Expanded(
          flex: dueTotal,
          child: const ColoredBox(color: AppColors.streak),
        ),
    ];
    if (segments.isEmpty) {
      segments.add(const Expanded(child: ColoredBox(color: AppColors.surface2)));
    }

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
                Text('$total장 중 $reviewedTotal 완료', style: textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 세그먼트 진행 바: 완료/복습 대기 (dueCount·reviewedCount 실데이터)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: SizedBox(height: 10, child: Row(children: segments)),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Wrap(
              spacing: AppSpacing.md,
              children: <Widget>[
                _Legend(color: AppColors.success, label: '완료'),
                _Legend(color: AppColors.streak, label: '복습 대기'),
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
          // 추가 버튼 (있을 때만)
          if (column.addLabel != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: _MiniAddButton(
                label: column.addLabel!,
                onTap: () => context.go(column.addRoute!),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
