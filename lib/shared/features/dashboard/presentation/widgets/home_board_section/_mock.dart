part of '../home_board_section.dart';

// ── 보드 모델 ────────────────────────────────────────────────────────────────

/// 보드 타일 종류(안정적 id 역할).
enum _BoardKind {
  ask,
  todayReview,
  suggest,
  insight,
  streak,
  level,
  graph,
  recentNotes,
  ranking,
}

/// 타일이 차지하는 가로 폭.
enum _TileWidth { full, half }

/// 보드 타일 1개를 기술하는 모델(카탈로그 엔트리).
class _BoardSpec {
  const _BoardSpec({
    required this.kind,
    required this.label,
    required this.emoji,
    required this.width,
  });

  final _BoardKind kind;
  final String label;

  /// 타일 헤더 · 추가 바 썸네일에 쓰는 이모지(ask 타일은 SynapseOrb로 대체).
  final String emoji;
  final _TileWidth width;
}

/// 사용 가능한 전체 위젯 카탈로그(추가 바의 모집단 · 시드 순서의 원본).
const List<_BoardSpec> _kCatalog = <_BoardSpec>[
  _BoardSpec(
    kind: _BoardKind.ask,
    label: 'AI 질문',
    emoji: '✦',
    width: _TileWidth.full,
  ),
  _BoardSpec(
    kind: _BoardKind.todayReview,
    label: '오늘 복습',
    emoji: '📚',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.suggest,
    label: 'AI 추천',
    emoji: '🩺',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.insight,
    label: '이번 주 인사이트',
    emoji: '📈',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.streak,
    label: '스트릭',
    emoji: '🔥',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.level,
    label: '내 프로필',
    emoji: '⭐',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.graph,
    label: '지식 그래프',
    emoji: '🕸',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.recentNotes,
    label: '최근 노트',
    emoji: '📝',
    width: _TileWidth.half,
  ),
  _BoardSpec(
    kind: _BoardKind.ranking,
    label: '그룹 랭킹',
    emoji: '🏆',
    width: _TileWidth.half,
  ),
];

_BoardSpec _specFor(_BoardKind kind) =>
    _kCatalog.firstWhere((_BoardSpec spec) => spec.kind == kind);

// ── Mock data (tutor 화면에서 가져온 값) ─────────────────────────────────────
// TODO: 팀원 구현 — 보드 구성 영속화 / 각 svc 데이터 연동
const int _kReviewCardCount = 18;
const int _kStreakDays = 14;
const int _kStreakBest = 21;
const int _kWeeklyReviews = 152;
const int _kWeeklyAccuracy = 94;
const int _kWeeklyXp = 420;

class _MockNote {
  const _MockNote({required this.title, required this.timeAgo});
  final String title;
  final String timeAgo;
}

const List<_MockNote> _kMockNotes = <_MockNote>[
  _MockNote(title: '운영체제 가상 메모리 정리', timeAgo: '30분 전'),
  _MockNote(title: 'Flutter 상태 관리 패턴', timeAgo: '2시간 전'),
  _MockNote(title: '이산수학 그래프 이론', timeAgo: '어제'),
];

class _RankRow {
  const _RankRow({
    required this.rank,
    required this.name,
    required this.xp,
    this.highlight = false,
  });
  final int rank;
  final String name;
  final int xp;
  final bool highlight;
}

const List<_RankRow> _kRanking = <_RankRow>[
  _RankRow(rank: 1, name: '민지', xp: 980),
  _RankRow(rank: 2, name: '준호', xp: 760),
  _RankRow(rank: 3, name: '나(김시냅스)', xp: 420, highlight: true),
];
