import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CalendarSection — 대시보드 캘린더 섹션(월 캘린더 · 주간 스트립 · 오늘 아젠다)
//
// 앱 셸 내부의 대시보드 탭에 배치되는 BODY 전용 위젯이다. Scaffold/AppBar 없이
// 스크롤 가능한 본문만 반환한다. 가용 폭이 넓으면(>=820) 월 캘린더와 오늘 아젠다를
// 좌우로, 좁으면 주간 스트립 + 아젠다를 세로로 쌓는다(아젠다 폭 확보).
// ═══════════════════════════════════════════════════════════════════════════

class CalendarSection extends StatelessWidget {
  const CalendarSection({this.scrollable = true, super.key});

  // false면 루트 ListView가 자체 스크롤하지 않고(shrinkWrap), 외부 스크롤 뷰가
  // 스크롤을 담당한다(임베드 모드).
  final bool scrollable;

  // 셸 사이드바를 제외한 실제 가용 너비 기준. 좌우 배치 시 아젠다(flex 2)가
  // 충분한 폭을 갖도록 창 전체가 아닌 LayoutBuilder 제약폭으로 판단한다.
  static const double _wideBreakpoint = 820;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= _wideBreakpoint;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          shrinkWrap: !scrollable,
          physics: scrollable ? null : const NeverScrollableScrollPhysics(),
          children: [
            if (isWide)
              // NOTE: IntrinsicHeight + GridView(shrinkWrap)는 그리드 intrinsic
              // 높이를 0으로 보고해 달력이 짧은 아젠다 높이로 잘린다. 각 컬럼이
              // 자연 높이를 갖도록 IntrinsicHeight 없이 상단 정렬한다.
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _MonthCalendar()),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: _PanelCard(title: '오늘 아젠다', child: _TodayAgenda()),
                  ),
                ],
              )
            else ...const [
              _WeekStrip(),
              SizedBox(height: AppSpacing.md),
              _PanelCard(title: '오늘 아젠다', child: _TodayAgenda()),
            ],
          ],
        );
      },
    );
  }
}

// ── Mock data ──────────────────────────────────────────────────────────────
// TODO: 팀원 구현 — learning-svc / knowledge-svc 연동 시 아래 mock 데이터를
// Provider로 교체한다. Phase 1(디자인)에서는 mock 그대로 사용한다.

/// 주간 스트립 — (요일, 일자, 복습 부하 0~1, 오늘 여부)
const List<_WeekDay> _kWeekDays = <_WeekDay>[
  _WeekDay('월', 28, 0.55, false),
  _WeekDay('화', 29, 1.0, true),
  _WeekDay('수', 30, 0.45, false),
  _WeekDay('목', 31, 0.60, false),
  _WeekDay('금', 1, 0.38, false),
  _WeekDay('토', 2, 0.70, false),
  _WeekDay('일', 3, 0.42, false),
];

/// 오늘 아젠다(타임블록) mock
const List<_AgendaBlock> _kTodayAgenda = <_AgendaBlock>[
  _AgendaBlock(
    time: '09:00',
    duration: '30분',
    title: 'ML 기초 복습',
    subtitle: '간격반복 예정 · 정규화/과적합 카드',
    badge: '8장 due',
    kind: _BlockKind.review,
  ),
  _AgendaBlock(
    time: '14:00',
    duration: '45분',
    title: '새 노트 정리',
    subtitle: '「트랜스포머」 어텐션 메커니즘 정리',
    badge: '노트',
    kind: _BlockKind.note,
  ),
  _AgendaBlock(
    time: '20:00',
    duration: '20분',
    title: 'AWS SAA 복습',
    subtitle: '간격반복 예정 · 자격증 덱',
    badge: '5장 due',
    kind: _BlockKind.review,
  ),
  // v1 미배치 블록 — 시간 미지정, 탭하여 시간 지정 (아젠다 시그니처)
  _AgendaBlock(
    time: '--:--',
    duration: '미배치',
    title: '프로그래밍 복습',
    subtitle: '미배치 · 탭하여 시간 지정',
    badge: '5장',
    kind: _BlockKind.note,
  ),
];

enum _BlockKind { review, note, community }

class _WeekDay {
  const _WeekDay(this.dow, this.day, this.load, this.isToday);
  final String dow;
  final int day;
  final double load; // 0~1
  final bool isToday;
}

class _AgendaBlock {
  const _AgendaBlock({
    required this.time,
    required this.duration,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.kind,
  });
  final String time;
  final String duration;
  final String title;
  final String subtitle;
  final String badge;
  final _BlockKind kind;

  Color get accent => switch (kind) {
    _BlockKind.review => AppColors.primary,
    _BlockKind.note => AppColors.accent,
    _BlockKind.community => AppColors.streak,
  };
}

/// 복습 부하(0~1)에 따른 톤. surface2 ↔ primary 사이를 보간.
Color _loadColor(double load) {
  return Color.lerp(AppColors.surface2, AppColors.primary, load.clamp(0, 1))!;
}

// ── 섹션 라벨 ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.muted,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ── 패널 카드(아젠다 컨테이너) ──────────────────────────────────────────────

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(title),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

// ── 주간 스트립(모바일) — 요일별 복습 부하 막대 ──────────────────────────────

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            Row(
              children: [
                for (final _WeekDay d in _kWeekDays)
                  Expanded(child: _dayCell(textTheme, d)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '복습 부하',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(width: AppSpacing.sm),
                _scaleSwatch(0.38),
                _scaleSwatch(0.6),
                _scaleSwatch(1.0),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '적음→많음',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scaleSwatch(double load) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1.5),
    child: Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: _loadColor(load),
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );

  Widget _dayCell(TextTheme textTheme, _WeekDay d) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: d.isToday ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Text(
            d.dow,
            style: textTheme.labelSmall?.copyWith(
              color: d.isToday ? AppColors.primaryFg : AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${d.day}',
            style: textTheme.titleSmall?.copyWith(
              color: d.isToday ? AppColors.primaryFg : AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          // 부하 막대
          Container(
            width: 14,
            height: 8 + 22 * d.load,
            decoration: BoxDecoration(
              color: d.isToday ? AppColors.primaryFg : _loadColor(d.load),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
                bottom: Radius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 오늘 아젠다(타임블록 타임라인) ──────────────────────────────────────────

class _TodayAgenda extends StatelessWidget {
  const _TodayAgenda();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _kTodayAgenda.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == _kTodayAgenda.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: _AgendaTile(block: _kTodayAgenda[i]),
          ),
      ],
    );
  }
}

class _AgendaTile extends StatelessWidget {
  const _AgendaTile({required this.block});
  final _AgendaBlock block;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 시간 컬럼
        SizedBox(
          width: 46,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  block.time,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  block.duration,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // 본문 카드(좌측 컬러 보더)
        // NOTE: 비균일 색 Border(left만 accent)에 borderRadius를 주면 paint 시
        // 'borderRadius can only be given on borders with uniform colors' 단언으로
        // 크래시한다. 둥근 모서리는 균일 Border.all로 그리고, 좌측 컬러 스트립은
        // ClipRRect 안의 별도 레이어(Stack)로 렌더한다.
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(width: 4, color: block.accent),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              block.title,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: block.accent.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              block.badge,
                              style: textTheme.labelSmall?.copyWith(
                                color: block.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        block.subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 월 캘린더 그리드(데스크탑) ──────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar();

  static const List<String> _dows = ['일', '월', '화', '수', '목', '금', '토'];

  /// 5월 2026 그리드. (일자, 이전/다음달 여부, 오늘 여부, 복습 due, 부하 0~1)
  // TODO: 팀원 구현 — learning-svc 연동 시 월 그리드 셀을 Provider로 교체한다.
  List<_CalCell> get _cells {
    // 4/26(일) ~ 6/6 까지 6주 그리드. 부하/복습은 mock.
    return const [
      _CalCell(26, out: true),
      _CalCell(27, out: true),
      _CalCell(28, load: 0.65),
      _CalCell(29, due: 6, load: 0.5),
      _CalCell(30, load: 0.3),
      _CalCell(1),
      _CalCell(2, load: 0.55),
      _CalCell(3),
      _CalCell(4, due: 9, load: 0.75),
      _CalCell(5, load: 0.35),
      _CalCell(6),
      _CalCell(7, load: 0.55),
      _CalCell(8, due: 12, load: 0.9),
      _CalCell(9, load: 0.4),
      _CalCell(10),
      _CalCell(11, load: 0.5),
      _CalCell(12, due: 7, load: 0.55),
      _CalCell(13, load: 0.3),
      _CalCell(14),
      _CalCell(15, load: 0.7),
      _CalCell(16, load: 0.35),
      _CalCell(17),
      _CalCell(18, due: 8, load: 0.7),
      _CalCell(19, load: 0.4),
      _CalCell(20, load: 0.5),
      _CalCell(21),
      _CalCell(22, load: 0.6),
      _CalCell(23, due: 11, load: 0.85),
      _CalCell(24, load: 0.3),
      _CalCell(25, load: 0.45),
      _CalCell(26, due: 9, load: 0.5),
      _CalCell(27, load: 0.5),
      _CalCell(28, due: 11, load: 0.7),
      _CalCell(29, today: true, due: 18, load: 1.0),
      _CalCell(30, due: 9, load: 0.55),
      _CalCell(31, due: 12, load: 0.65),
      _CalCell(1, out: true, load: 0.35),
      _CalCell(2, out: true, due: 14, load: 0.78),
      _CalCell(3, out: true, load: 0.4),
      _CalCell(4, out: true),
      _CalCell(5, out: true, load: 0.5),
      _CalCell(6, out: true, load: 0.3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // 요일 헤더
            Row(
              children: [
                for (int i = 0; i < _dows.length; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        _dows[i],
                        style: textTheme.labelSmall?.copyWith(
                          color: i == 0 ? AppColors.error : AppColors.muted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 날짜 그리드 (6주 x 7일)
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.82,
              children: [
                for (int i = 0; i < _cells.length; i++)
                  _CalDayCell(cell: _cells[i], isSunday: i % 7 == 0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalCell {
  const _CalCell(
    this.day, {
    this.out = false,
    this.today = false,
    this.due = 0,
    this.load = 0,
  });
  final int day;
  final bool out;
  final bool today;
  final int due;
  final double load;
}

class _CalDayCell extends StatelessWidget {
  const _CalDayCell({required this.cell, required this.isSunday});
  final _CalCell cell;
  final bool isSunday;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color dayColor = isSunday ? AppColors.error : AppColors.text;

    return Opacity(
      opacity: cell.out ? 0.4 : 1,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: cell.today
              ? AppColors.primary.withValues(alpha: 0.10)
              : AppColors.bg,
          border: Border.all(
            color: cell.today ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${cell.day}',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cell.today ? AppColors.primary : dayColor,
              ),
            ),
            if (cell.due > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '복습 ${cell.due}',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (cell.load > 0)
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 18,
                  height: 4 + 16 * cell.load,
                  decoration: BoxDecoration(
                    color: _loadColor(cell.load),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                      bottom: Radius.circular(1),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
