import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/learning/features/stats/providers/learning_stats_providers.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/calendar_section.dart';

void main() {
  Future<void> pump(WidgetTester tester, List<Override> overrides) async {
    const size = Size(1440, 900);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: CalendarSection()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  testWidgets('밀린 복습이 있으면 배지가 노출된다', (tester) async {
    final today = DateTime.now();
    await pump(tester, [
      reviewForecastProvider.overrideWith(
        (ref, range) async => ReviewForecast(
          overdueCount: 7,
          days: [ForecastDay(date: DateTime(today.year, today.month, today.day), dueCount: 12)],
        ),
      ),
      dailyReviewStatsProvider.overrideWith((ref, range) async => const <DailyReviewStat>[]),
    ]);

    expect(find.textContaining('밀린 7장'), findsOneWidget);
  });

  testWidgets('밀린 복습이 없으면 배지가 없다', (tester) async {
    await pump(tester, [
      reviewForecastProvider.overrideWith(
        (ref, range) async => const ReviewForecast(overdueCount: 0, days: []),
      ),
      dailyReviewStatsProvider.overrideWith((ref, range) async => const <DailyReviewStat>[]),
    ]);

    expect(find.textContaining('밀린'), findsNothing);
  });

  testWidgets('실적 조회 구간이 주간 스트립이 그리는 이번 주 월요일을 포함한다', (
    tester,
  ) async {
    // 월 그리드는 일요일 시작, 주간 스트립은 월요일 시작(ISO)이라 관례가
    // 다르다. 1일이 일요일인 달의 1일 당일에는 이번 주 월요일이 월 그리드
    // 시작일보다 앞서므로, 실적(daily) 조회 구간이 gridStart부터만 잡히면
    // weekStart~1일 전날 구간이 어느 provider 구간에도 포함되지 않아 주간
    // 스트립이 그 날짜들을 항상 0으로 그린다. 오늘 날짜와 무관하게 항상
    // 성립해야 하는 불변조건이므로 실제 DateTime.now()로 검증한다.
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final weekStart = startOfToday.subtract(
      Duration(days: startOfToday.weekday - DateTime.monday),
    );

    StatsDateRange? capturedDailyRange;
    await pump(tester, [
      reviewForecastProvider.overrideWith(
        (ref, range) async => const ReviewForecast(overdueCount: 0, days: []),
      ),
      dailyReviewStatsProvider.overrideWith((ref, range) async {
        capturedDailyRange = range;
        return const <DailyReviewStat>[];
      }),
    ]);

    expect(capturedDailyRange, isNotNull);
    expect(
      capturedDailyRange!.from.isAfter(weekStart),
      isFalse,
      reason:
          '주간 스트립이 그리는 이번 주 월요일(${weekStart.toIso8601String()})이 '
          '실적 조회 구간 시작(${capturedDailyRange!.from.toIso8601String()})보다 '
          '앞서면 그 날짜는 실적 데이터가 없어 항상 0으로 그려진다.',
    );
  });
}
