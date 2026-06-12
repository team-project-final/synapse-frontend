import 'package:flutter/foundation.dart';

/// 대시보드 보드 구성 — 표시할 위젯 id의 순서 있는 목록.
/// id는 보드 위젯 enum 의 name(예: 'ask', 'todayReview')과 일치한다.
@immutable
class BoardConfig {
  const BoardConfig({required this.widgetIds});

  /// 디바이스에 저장된 구성이 없을 때 쓰는 기본 보드(카탈로그 표시 순서).
  static const BoardConfig defaults = BoardConfig(
    widgetIds: <String>[
      'ask',
      'todayReview',
      'suggest',
      'insight',
      'streak',
      'level',
      'graph',
      'recentNotes',
      'ranking',
    ],
  );

  final List<String> widgetIds;

  BoardConfig copyWithout(String id) => BoardConfig(
    widgetIds: widgetIds.where((String w) => w != id).toList(growable: false),
  );

  BoardConfig copyWithAdded(String id) => widgetIds.contains(id)
      ? this
      : BoardConfig(widgetIds: <String>[...widgetIds, id]);

  @override
  bool operator ==(Object other) =>
      other is BoardConfig && listEquals(other.widgetIds, widgetIds);

  @override
  int get hashCode => Object.hashAll(widgetIds);
}

/// 보드 구성 영속화 Port. 저장 매체(Hive/SQLite 등)에 무지하다.
abstract interface class BoardConfigRepositoryPort {
  /// 저장된 구성. 없으면 null (호출부가 [BoardConfig.defaults] 폴백).
  Future<BoardConfig?> load();

  Future<void> save(BoardConfig config);
}
