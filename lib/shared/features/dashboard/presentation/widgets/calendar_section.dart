import 'package:flutter/material.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CalendarSection — 대시보드 캘린더 섹션(월 캘린더 · 주간 스트립)
// ═══════════════════════════════════════════════════════════════════════════

class CalendarSection extends StatelessWidget {
  const CalendarSection({
    this.scrollable = true,
    this.selectedDate,
    this.onDateSelected,
    super.key,
  });

  final bool scrollable;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  static const double _wideBreakpoint = 820;

  @override
  Widget build(BuildContext context) {
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
            if (isWide)
              _MonthCalendar(
                selectedDate: selectedDate,
                onDateSelected: onDateSelected,
              )
            else
              _WeekStrip(
                selectedDate: selectedDate,
                onDateSelected: onDateSelected,
              ),
          ],
        );
      },
    );
  }
}

// ── 공통 유틸 ──────────────────────────────────────────────────────────────

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ── 주간 스트립(모바일) ───────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({this.selectedDate, this.onDateSelected});

  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  static const List<String> _dowLabels = ['월', '화', '수', '목', '금', '토', '일'];

  // 이번 주 월요일
  DateTime get _weekStart {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime weekStart = _weekStart;
    final DateTime today = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            for (int i = 0; i < 7; i++)
              Expanded(
                child: _dayCell(
                  textTheme,
                  _dowLabels[i],
                  weekStart.add(Duration(days: i)),
                  today,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(
    TextTheme textTheme,
    String dow,
    DateTime date,
    DateTime today,
  ) {
    final bool selected =
        selectedDate != null && _isSameDay(date, selectedDate!);
    final bool isToday = _isSameDay(date, today);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDateSelected == null ? null : () => onDateSelected!(date),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
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
          ],
        ),
      ),
    );
  }
}

// ── 월 캘린더 그리드(데스크탑) ───────────────────────────────────────────

class _MonthCalendar extends StatefulWidget {
  const _MonthCalendar({this.selectedDate, this.onDateSelected});

  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  State<_MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<_MonthCalendar> {
  late DateTime _displayMonth;

  static const List<String> _dows = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  // 표시 달의 1일이 속한 주의 일요일
  DateTime get _gridStart {
    final DateTime first = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final int offset = first.weekday % 7; // Mon=1..Sat=6, Sun=0
    return first.subtract(Duration(days: offset));
  }

  // 6주 × 7일 = 42칸 동적 생성
  List<_CalCell> get _cells {
    final DateTime today = DateTime.now();
    final DateTime start = _gridStart;
    return List.generate(42, (int i) {
      final DateTime date = start.add(Duration(days: i));
      return _CalCell(
        date.day,
        out: date.month != _displayMonth.month ||
            date.year != _displayMonth.year,
        today: _isSameDay(date, today),
      );
    });
  }

  void _prevMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month + 1);
      });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime gridStart = _gridStart;
    final List<_CalCell> cells = _cells;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // 월 헤더 + 이전/다음 버튼
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
                left: 2,
                right: 2,
              ),
              child: Row(
                children: [
                  Text(
                    '${_displayMonth.year}년 ${_displayMonth.month}월',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _prevMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                    color: AppColors.muted,
                  ),
                ],
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
                          color:
                              i == 0 ? AppColors.error : AppColors.muted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 날짜 그리드 (6주 × 7일)
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.9,
              children: [
                for (int i = 0; i < cells.length; i++)
                  _CalDayCell(
                    cell: cells[i],
                    isSunday: i % 7 == 0,
                    date: gridStart.add(Duration(days: i)),
                    selectedDate: widget.selectedDate,
                    onDateSelected: widget.onDateSelected,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 캘린더 셀 데이터 ────────────────────────────────────────────────────────

class _CalCell {
  const _CalCell(this.day, {this.out = false, this.today = false});
  final int day;
  final bool out;
  final bool today;
}

// ── 날짜 셀 위젯 ────────────────────────────────────────────────────────────

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
        opacity: cell.out ? 0.35 : 1,
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
            ],
          ),
        ),
      ),
    );
  }
}
