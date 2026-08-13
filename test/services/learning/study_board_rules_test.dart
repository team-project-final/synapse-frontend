import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/learning/features/stats/domain/study_board_rules.dart';

DeckSummary _deck({
  int totalCards = 0,
  int unreviewedCards = 0,
  int dueCount = 0,
  int reviewedCount = 0,
}) {
  return DeckSummary(
    deckId: 'd1',
    name: '테스트 덱',
    totalCards: totalCards,
    unreviewedCards: unreviewedCards,
    dueCount: dueCount,
    reviewedCount: reviewedCount,
  );
}

void main() {
  test('due가 있으면 복습 대기', () {
    expect(
      classifyDeck(_deck(totalCards: 10, dueCount: 3)),
      StudyBoardColumn.due,
    );
  });

  test('due와 reviewed가 동시에 있으면 복습 대기가 우선', () {
    expect(
      classifyDeck(_deck(totalCards: 10, dueCount: 3, reviewedCount: 5)),
      StudyBoardColumn.due,
    );
  });

  test('due가 없고 그날 복습했으면 완료', () {
    expect(
      classifyDeck(_deck(totalCards: 10, reviewedCount: 5)),
      StudyBoardColumn.done,
    );
  });

  test('카드가 0장이면 수집함', () {
    expect(classifyDeck(_deck()), StudyBoardColumn.collect);
  });

  test('미복습 카드만 있으면 학습 중', () {
    expect(
      classifyDeck(_deck(totalCards: 10, unreviewedCards: 4)),
      StudyBoardColumn.learning,
    );
  });

  test('전부 복습됐고 오늘 due가 없으면 완료', () {
    expect(classifyDeck(_deck(totalCards: 10)), StudyBoardColumn.done);
  });

  test('메타 문구가 컬럼에 맞게 나온다', () {
    expect(deckMetaLabel(_deck(totalCards: 10, dueCount: 8)), '⏰ 오늘 8장');
    expect(deckMetaLabel(_deck(totalCards: 10, reviewedCount: 5)), '✓ 오늘 5장 완료');
    expect(deckMetaLabel(_deck()), '카드 없음');
    expect(deckMetaLabel(_deck(totalCards: 10, unreviewedCards: 4)), '새 카드 4장');
    expect(deckMetaLabel(_deck(totalCards: 10)), '✓ 다음 복습 대기');
  });

  test('loadRatio는 최댓값이 0이면 0을 반환한다', () {
    expect(loadRatio(0, 0), 0);
    expect(loadRatio(5, 0), 0);
  });

  test('loadRatio는 0~1로 정규화하고 범위를 넘지 않는다', () {
    expect(loadRatio(5, 10), 0.5);
    expect(loadRatio(10, 10), 1.0);
    expect(loadRatio(15, 10), 1.0);
  });
}
