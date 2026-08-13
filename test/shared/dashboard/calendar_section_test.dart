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
}
