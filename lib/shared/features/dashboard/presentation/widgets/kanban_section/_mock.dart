part of '../kanban_section.dart';

/// 칸반 카드 한 장의 mock 모델.
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

/// 칸반 컬럼 한 개의 mock 모델.
class _KanbanColumn {
  const _KanbanColumn({
    required this.title,
    required this.stripColor,
    required this.cards,
    this.addLabel,
    this.addRoute,
  });

  final String title;
  final Color stripColor;
  final List<_KanbanCard> cards;
  final String? addLabel;
  final String? addRoute;

  int get wip => cards.length;
}

// 새 노트 작성 라우트 (AppRoutes.noteEditorPath('new') 와 동일하나
// const 보드 정의를 위해 리터럴로 둔다).
const String _kComposeRoute = '/notes/new/edit';

// TODO: 팀원 구현 — learning-svc / knowledge-svc 보드 데이터 연동
const List<_KanbanColumn> _kBoardColumns = [
  // 수집함
  _KanbanColumn(
    title: '수집함',
    stripColor: AppColors.columnCollect,
    addLabel: '+ 캡처 추가',
    addRoute: _kComposeRoute,
    cards: [
      _KanbanCard(
        title: 'CAP 정리',
        tag: '#아키텍처',
        meta: '방금 캡처',
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: 'Kubernetes',
        tag: '#DevOps',
        meta: '새 노트',
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: '동적 계획법',
        tag: '#알고리즘',
        meta: '웹 클리핑',
        route: AppRoutes.notes,
      ),
    ],
  ),
  // 학습 중
  _KanbanColumn(
    title: '학습 중',
    stripColor: AppColors.columnLearn,
    addLabel: '✨ AI 카드 생성',
    addRoute: AppRoutes.aiCards,
    cards: [
      _KanbanCard(
        title: '트랜스포머',
        tag: '#딥러닝',
        meta: '카드 4장 생성됨',
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: '어텐션 메커니즘',
        tag: '#딥러닝',
        meta: '읽는 중',
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: 'REST API',
        tag: '#백엔드',
        meta: '초안',
        route: AppRoutes.notes,
      ),
    ],
  ),
  // 복습 대기
  _KanbanColumn(
    title: '복습 대기',
    stripColor: AppColors.columnReview,
    cards: [
      _KanbanCard(
        title: 'ML 기초',
        tag: '#머신러닝',
        meta: '⏰ 오늘 8장',
        metaStatus: _MetaStatus.warn,
        route: AppRoutes.review,
      ),
      _KanbanCard(
        title: '프로그래밍',
        tag: '#알고리즘',
        meta: '⏰ 오늘 5장',
        metaStatus: _MetaStatus.warn,
        route: AppRoutes.review,
      ),
      _KanbanCard(
        title: 'AWS SAA',
        tag: '#DevOps',
        meta: '⏰ 오늘 5장',
        metaStatus: _MetaStatus.warn,
        route: AppRoutes.review,
      ),
    ],
  ),
  // 완료
  _KanbanColumn(
    title: '완료',
    stripColor: AppColors.columnDone,
    cards: [
      _KanbanCard(
        title: '과적합',
        tag: '#머신러닝',
        meta: '✓ 9일 뒤 재복습',
        metaStatus: _MetaStatus.ok,
        route: AppRoutes.notes,
      ),
      _KanbanCard(
        title: '드롭아웃',
        tag: '#머신러닝',
        meta: '✓ 21일 뒤',
        metaStatus: _MetaStatus.ok,
        route: AppRoutes.notes,
      ),
    ],
  ),
];
