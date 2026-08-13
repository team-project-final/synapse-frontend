import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/learning/features/stats/domain/study_board_rules.dart';
import 'package:synapse_frontend/services/learning/features/stats/providers/learning_stats_providers.dart';
import 'package:synapse_frontend/shared/widgets/app_state_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CalendarSection — 대시보드 캘린더 섹션(월 캘린더 · 주간 스트립)
//
// 앱 셸 내부의 플래너 화면(PlannerSection)에 배치되는 BODY 전용 위젯이다. Scaffold/AppBar 없이
// 스크롤 가능한 본문만 반환한다. 가용 폭이 넓으면(>=820) 월 캘린더를,
// 좁으면 주간 스트립을 표시한다.
//
// 복습 부하는 두 소스를 날짜 기준으로 나눠 쓴다: 오늘 이전(과거) 칸은
// dailyReviewStatsProvider(실적), 오늘을 포함한 이후(미래) 칸은
// reviewForecastProvider(예정)다. 과거 칸을 forecast로 칠하면 이미 소진된
// due라 항상 0으로 보여 캘린더가 텅 비게 된다. overdueCount(밀린 카드)는
// 오늘 칸 색에 합치지 않고 범례 옆 배지로만 별도 표시한다(합치면 오늘이
// 실제보다 과장되어 보인다).
// ═══════════════════════════════════════════════════════════════════════════

class CalendarSection extends ConsumerWidget {
  const CalendarSection({
    this.scrollable = true,
    this.selectedDate,
    this.onDateSelected,
    super.key,
  });

  // false면 루트 ListView가 자체 스크롤하지 않고(shrinkWrap), 외부 스크롤 뷰가
  // 스크롤을 담당한다(임베드 모드).
  final bool scrollable;

  // 선택된 날짜. 플래너에서 이 날짜를 강조하고, 날짜 탭 시 onDateSelected로
  // 알린다. null이면 날짜 탭/선택 강조가 비활성된다.
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  // 월 캘린더/주간 스트립 분기 기준 폭. 창 전체가 아닌 LayoutBuilder
  // 제약폭(셸 사이드바 제외 실제 가용 너비)으로 판단한다.
  static const double _wideBreakpoint = 820;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _startOfToday();
    final gridStart = _monthGridStartOf(today);
    final gridEnd = gridStart.add(const Duration(days: 41));
    // 월 그리드는 일요일 시작, 주간 스트립은 월요일 시작(ISO)이라 관례가
    // 다르다. 1일이 일요일인 달의 1일 당일에는 weekStart(전달 마지막 주
    // 월요일)가 gridStart(1일)보다 앞선다 — 두 시작점 중 이른 쪽부터
    // 실적을 조회해야 주간 스트립이 그리는 날짜가 항상 조회 구간에
    // 포함된다(92일 상한 안에서 충분히 여유 있음).
    final weekStart = _weekStartOf(today);
    final dailyRangeStart = gridStart.isBefore(weekStart)
        ? gridStart
        : weekStart;
    final forecastRange = StatsDateRange(from: today, to: gridEnd);
    final dailyRange = StatsDateRange(from: dailyRangeStart, to: today);

    final forecastAsync = ref.watch(reviewForecastProvider(forecastRange));
    final dailyAsync = ref.watch(dailyReviewStatsProvider(dailyRange));
    final loadAsync = _combineCalendarLoad(forecastAsync, dailyAsync);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= _wideBreakpoint;

        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shrinkWrap: !scrollable,
          physics: scrollable ? null : const NeverScrollableScrollPhysics(),
          children: [
            AppAsyncValueWidget<_CalendarLoad>(
              value: loadAsync,
              data: (load) => isWide
                  ? _MonthCalendar(
                      load: load,
                      today: today,
                      selectedDate: selectedDate,
                      onDateSelected: onDateSelected,
                    )
                  : _WeekStrip(
                      load: load,
                      today: today,
                      selectedDate: selectedDate,
                      onDateSelected: onDateSelected,
                    ),
              error: (Object error, StackTrace stackTrace) => AppErrorWidget(
                message: '캘린더를 불러오지 못했습니다.',
                onRetry: () {
                  ref.invalidate(reviewForecastProvider(forecastRange));
                  ref.invalidate(dailyReviewStatsProvider(dailyRange));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 두 provider의 [AsyncValue]를 하나로 합친다. 어느 한쪽이라도 에러면 에러,
/// 둘 다 데이터가 있어야 데이터. [AppAsyncValueWidget]가 로딩/에러 분기를
/// 한 곳에서 처리할 수 있도록 한다.
AsyncValue<_CalendarLoad> _combineCalendarLoad(
  AsyncValue<ReviewForecast> forecast,
  AsyncValue<List<DailyReviewStat>> daily,
) {
  if (forecast.hasError) {
    return AsyncValue.error(
      forecast.error!,
      forecast.stackTrace ?? StackTrace.current,
    );
  }
  if (daily.hasError) {
    return AsyncValue.error(
      daily.error!,
      daily.stackTrace ?? StackTrace.current,
    );
  }
  final forecastValue = forecast.value;
  final dailyValue = daily.value;
  if (forecastValue == null || dailyValue == null) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data(
    _CalendarLoad(forecast: forecastValue, daily: dailyValue),
  );
}

DateTime _startOfToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// 주간 스트립: 이번 주 월요일부터 7일.
DateTime _weekStartOf(DateTime date) =>
    date.subtract(Duration(days: date.weekday - DateTime.monday));

/// 월 그리드: 해당 월 1일이 속한 주의 일요일부터 6주(42칸).
DateTime _monthGridStartOf(DateTime date) {
  final first = DateTime(date.year, date.month, 1);
  return first.subtract(Duration(days: first.weekday % 7));
}

/// 캘린더 한 칸의 색을 결정하는 데 필요한 값. 과거는 실적, 미래는 예정.
class _CalendarLoad {
  const _CalendarLoad({required this.forecast, required this.daily});

  final ReviewForecast forecast;
  final List<DailyReviewStat> daily;

  int countOn(DateTime date, DateTime today) {
    if (date.isBefore(today)) {
      for (final stat in daily) {
        if (_isSameDay(stat.date, date)) return stat.reviewCount;
      }
      return 0;
    }
    return forecast.dueCountOn(date);
  }

  int get maxCount {
    var max = forecast.maxDueCount;
    for (final stat in daily) {
      if (stat.reviewCount > max) max = stat.reviewCount;
    }
    return max;
  }
}

/// 복습 부하(0~1)에 따른 톤. surface2 ↔ primary 사이를 보간.
Color _loadColor(double load) {
  return Color.lerp(AppColors.surface2, AppColors.primary, load.clamp(0, 1))!;
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ── 범례 — 복습 부하 스케일 + 밀린 복습 배지 ─────────────────────────────────
// 월 캘린더·주간 스트립 양쪽에서 공유한다.

class _LoadLegend extends StatelessWidget {
  const _LoadLegend({required this.forecast});

  final ReviewForecast forecast;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '복습 부하(지난 날은 실적, 앞으로는 예정)',
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
        if (forecast.overdueCount > 0)
          Text(
            '밀린 ${forecast.overdueCount}장',
            style: textTheme.labelSmall?.copyWith(color: AppColors.error),
          ),
      ],
    );
  }

  static Widget _scaleSwatch(double load) => Padding(
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
}

// ── 주간 스트립(모바일) — 요일별 복습 부하 막대 ──────────────────────────────

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.load,
    required this.today,
    this.selectedDate,
    this.onDateSelected,
  });

  final _CalendarLoad load;
  final DateTime today;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  static const List<String> _dowLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime weekStart = _weekStartOf(today);
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
                for (int i = 0; i < _dowLabels.length; i++)
                  Expanded(
                    child: _dayCell(
                      textTheme,
                      _dowLabels[i],
                      weekStart.add(Duration(days: i)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _LoadLegend(forecast: load.forecast),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(TextTheme textTheme, String dow, DateTime date) {
    final bool isToday = _isSameDay(date, today);
    final double dayLoad = loadRatio(load.countOn(date, today), load.maxCount);
    final bool selected =
        selectedDate != null && _isSameDay(date, selectedDate!);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDateSelected == null ? null : () => onDateSelected!(date),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          // 선택되지 않은 오늘은 보더로 표시.
          border: isToday && !selected
              ? Border.all(color: AppColors.primary)
              : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          children: [
            Text(
              dow,
              style: textTheme.labelSmall?.copyWith(
                color: selected ? AppColors.primaryFg : AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${date.day}',
              style: textTheme.titleSmall?.copyWith(
                color: selected ? AppColors.primaryFg : AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // 부하 막대
            Container(
              width: 14,
              height: 8 + 22 * dayLoad,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryFg : _loadColor(dayLoad),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                  bottom: Radius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 월 캘린더 그리드(데스크탑) ──────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.load,
    required this.today,
    this.selectedDate,
    this.onDateSelected,
  });

  final _CalendarLoad load;
  final DateTime today;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  static const List<String> _dows = ['일', '월', '화', '수', '목', '금', '토'];

  /// 이번 달 그리드 42칸. (일자, 이전/다음달 여부, 오늘 여부, 복습 수, 부하 0~1)
  List<_CalCell> _cellsFrom(DateTime gridStart) {
    return [
      for (int i = 0; i < 42; i++) _cellFor(gridStart.add(Duration(days: i))),
    ];
  }

  _CalCell _cellFor(DateTime date) {
    final int count = load.countOn(date, today);
    return _CalCell(
      date.day,
      out: date.month != today.month,
      today: _isSameDay(date, today),
      due: count,
      load: loadRatio(count, load.maxCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime gridStart = _monthGridStartOf(today);
    final List<_CalCell> cells = _cellsFrom(gridStart);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // 월 헤더 — 현재 표시 중인 달(YYYY년 M월)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
                left: 2,
                right: 2,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${today.year}년 ${today.month}월',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
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
                for (int i = 0; i < cells.length; i++)
                  _CalDayCell(
                    cell: cells[i],
                    isSunday: i % 7 == 0,
                    date: gridStart.add(Duration(days: i)),
                    selectedDate: selectedDate,
                    onDateSelected: onDateSelected,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _LoadLegend(forecast: load.forecast),
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
  const _CalDayCell({
    required this.cell,
    required this.isSunday,
    required this.date,
    this.selectedDate,
    this.onDateSelected,
  });
  final _CalCell cell;
  final bool isSunday;
  final DateTime date;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color dayColor = isSunday ? AppColors.error : AppColors.text;
    final bool selected =
        selectedDate != null && _isSameDay(date, selectedDate!);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDateSelected == null ? null : () => onDateSelected!(date),
      child: Opacity(
        opacity: cell.out ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.14)
                : AppColors.bg,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${cell.day}',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.primary : dayColor,
                    ),
                  ),
                  // 오늘 표시 점(선택과 별개로 항상 노출)
                  if (cell.today) ...[
                    const SizedBox(width: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              if (cell.due > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '복습 ${cell.due}',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      // 컴팩트한 달력 셀 — labelSmall(11)로 키우면 좁은 셀에서
                      // 넘칠 수 있어 9.5 유지.
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
      ),
    );
  }
}
