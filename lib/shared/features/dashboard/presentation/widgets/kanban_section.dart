import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';
import 'package:synapse_frontend/services/learning/features/stats/data/learning_stats_api.dart';
import 'package:synapse_frontend/services/learning/features/stats/domain/study_board_rules.dart';
import 'package:synapse_frontend/services/learning/features/stats/providers/learning_stats_providers.dart';
import 'package:synapse_frontend/shared/widgets/app_state_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Study Board (칸반)
//   덱의 학습 상태(StudyBoardColumn)에 따라 자동 분류되는 읽기 전용 보드.
//   deckSummariesProvider로 덱을 불러와 classifyDeck으로 4개 컬럼에 배치한다.
// ═══════════════════════════════════════════════════════════════════════════

part 'kanban_section/_mock.dart';
part 'kanban_section/board.dart';
part 'kanban_section/_card.dart';

/// 덱 목록을 [StudyBoardColumn] 기준으로 4개 칸반 컬럼에 배치한다.
List<_KanbanColumn> _buildColumns(List<DeckSummary> decks) {
  final byColumn = <StudyBoardColumn, List<_KanbanCard>>{
    for (final column in StudyBoardColumn.values) column: <_KanbanCard>[],
  };

  for (final deck in decks) {
    final column = classifyDeck(deck);
    byColumn[column]!.add(
      _KanbanCard(
        title: deck.name,
        tag: '카드 ${deck.totalCards}장',
        meta: deckMetaLabel(deck),
        metaStatus: switch (column) {
          StudyBoardColumn.due => _MetaStatus.warn,
          StudyBoardColumn.done => _MetaStatus.ok,
          _ => _MetaStatus.normal,
        },
        route: column == StudyBoardColumn.due
            ? AppRoutes.review
            : AppRoutes.deckCardsPath(deck.deckId),
      ),
    );
  }

  return [
    _KanbanColumn(
      title: '수집함',
      stripColor: AppColors.columnCollect,
      cards: byColumn[StudyBoardColumn.collect]!,
    ),
    _KanbanColumn(
      title: '학습 중',
      stripColor: AppColors.columnLearn,
      cards: byColumn[StudyBoardColumn.learning]!,
    ),
    _KanbanColumn(
      title: '복습 대기',
      stripColor: AppColors.columnReview,
      cards: byColumn[StudyBoardColumn.due]!,
    ),
    _KanbanColumn(
      title: '완료',
      stripColor: AppColors.columnDone,
      cards: byColumn[StudyBoardColumn.done]!,
    ),
  ];
}
