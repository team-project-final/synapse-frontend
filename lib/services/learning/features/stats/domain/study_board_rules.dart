import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';

/// 스터디 보드(칸반) 컬럼. 사용자가 카드를 옮기는 보드가 아니라
/// 덱의 학습 상태로 자동 분류되는 읽기 전용 뷰다.
enum StudyBoardColumn { collect, learning, due, done }

/// 덱 하나를 정확히 한 컬럼에 배치한다. 순서가 곧 우선순위다.
StudyBoardColumn classifyDeck(DeckSummary deck) {
  // 남은 복습이 있다는 사실이 그날 복습을 했다는 사실보다 중요하다.
  if (deck.dueCount > 0) return StudyBoardColumn.due;
  if (deck.reviewedCount > 0) return StudyBoardColumn.done;
  if (deck.totalCards == 0) return StudyBoardColumn.collect;
  if (deck.unreviewedCards > 0) return StudyBoardColumn.learning;
  return StudyBoardColumn.done;
}

String deckMetaLabel(DeckSummary deck) {
  return switch (classifyDeck(deck)) {
    StudyBoardColumn.due => '⏰ 오늘 ${deck.dueCount}장',
    StudyBoardColumn.collect => '카드 없음',
    StudyBoardColumn.learning => '새 카드 ${deck.unreviewedCards}장',
    StudyBoardColumn.done =>
      deck.reviewedCount > 0 ? '✓ 오늘 ${deck.reviewedCount}장 완료' : '✓ 다음 복습 대기',
  };
}

/// 복습 부하를 0~1로 정규화한다. 최댓값이 0이면 0(0 나눗셈 방지).
double loadRatio(int value, int max) {
  if (max <= 0) return 0;
  return (value / max).clamp(0, 1).toDouble();
}
