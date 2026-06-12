import 'package:hive_flutter/hive_flutter.dart';
import 'package:synapse_frontend/shared/features/dashboard/domain/board_config.dart';

/// [BoardConfigRepositoryPort] 의 Hive 구현.
/// 웹(IndexedDB)·모바일/데스크톱(파일) 동일 코드로 동작한다.
class HiveBoardConfigRepository implements BoardConfigRepositoryPort {
  const HiveBoardConfigRepository();

  static const String _boxName = 'synapse_dashboard';
  static const String _key = 'board_widget_ids';

  Future<Box<dynamic>> _openBox() async {
    await Hive.initFlutter(); // 중복 호출 안전 (token_store 와 동일 패턴)
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return Hive.openBox<dynamic>(_boxName);
  }

  @override
  Future<BoardConfig?> load() async {
    try {
      final Box<dynamic> box = await _openBox();
      final dynamic raw = box.get(_key);
      if (raw is! List) return null; // 미저장 → 디폴트 폴백은 호출부 책임
      return BoardConfig(widgetIds: raw.cast<String>());
    } catch (_) {
      // 로컬 저장소 장애(스토리지 차단·손상 등)가 대시보드 표출을 막으면 안 된다.
      // 미저장과 동일하게 취급해 디폴트 구성으로 폴백시킨다.
      return null;
    }
  }

  @override
  Future<void> save(BoardConfig config) async {
    try {
      final Box<dynamic> box = await _openBox();
      await box.put(_key, config.widgetIds);
    } catch (_) {
      // 저장 실패 시 다음 방문에 디폴트로 돌아갈 뿐, 현재 세션 동작엔 영향 없음.
    }
  }
}
