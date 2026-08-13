import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/learning/features/stats/providers/learning_stats_providers.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/kanban_section.dart';

DeckSummary _deck(String name, {int total = 0, int unreviewed = 0, int due = 0, int reviewed = 0}) {
  return DeckSummary(
    deckId: name,
    name: name,
    totalCards: total,
    unreviewedCards: unreviewed,
    dueCount: due,
    reviewedCount: reviewed,
  );
}

void main() {
  Future<void> pump(WidgetTester tester, List<DeckSummary> decks) async {
    const size = Size(1440, 900);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deckSummariesProvider.overrideWith((ref, date) async => decks),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: KanbanSection(date: DateTime(2026, 8, 13))),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  testWidgets('덱이 상태에 따라 각 컬럼에 배치된다', (tester) async {
    await pump(tester, [
      _deck('빈 덱'),
      _deck('학습 중 덱', total: 10, unreviewed: 4),
      _deck('복습 대기 덱', total: 10, due: 8),
      _deck('완료 덱', total: 10, reviewed: 5),
    ]);

    expect(find.text('빈 덱'), findsOneWidget);
    expect(find.text('카드 없음'), findsOneWidget);
    expect(find.text('새 카드 4장'), findsOneWidget);
    expect(find.text('⏰ 오늘 8장'), findsOneWidget);
    expect(find.text('✓ 오늘 5장 완료'), findsOneWidget);
  });

  testWidgets('덱이 하나도 없으면 안내 문구 하나만 보인다', (tester) async {
    await pump(tester, []);

    expect(find.text('아직 덱이 없습니다.'), findsOneWidget);
  });
}
