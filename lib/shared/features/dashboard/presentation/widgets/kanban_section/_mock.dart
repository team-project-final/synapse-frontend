part of '../kanban_section.dart';

/// 칸반 카드 한 장의 모델.
class _KanbanCard {
  const _KanbanCard({
    required this.title,
    required this.tag,
    required this.meta,
    this.metaStatus = _MetaStatus.normal,
    required this.route,
  });

  final String title;
  final String tag;
  final String meta;
  final _MetaStatus metaStatus;
  final String route;
}

enum _MetaStatus { normal, warn, ok }

/// 칸반 컬럼 한 개의 모델.
class _KanbanColumn {
  const _KanbanColumn({
    required this.title,
    required this.stripColor,
    required this.cards,
    // 현재 실데이터 조립(_buildColumns)은 두 값을 넘기지 않는다(수집함
    // "+ 캡처 추가" 등 컬럼별 액션 버튼은 이번 태스크 범위 밖). 필드/UI
    // 분기(board.dart _BoardColumn)는 그대로 유지해 두므로 호출부 없는
    // 선택 파라미터 경고만 억제한다.
    // ignore: unused_element_parameter
    this.addLabel,
    // ignore: unused_element_parameter
    this.addRoute,
  });

  final String title;
  final Color stripColor;
  final List<_KanbanCard> cards;
  final String? addLabel;
  final String? addRoute;

  int get wip => cards.length;
}
