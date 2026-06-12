import 'package:synapse_frontend/shared/features/dashboard/domain/board_config.dart';

/// 인메모리 보드 구성 저장소 fake.
///
/// 대시보드를 렌더링하는 위젯 테스트는 `boardConfigRepositoryProvider` 를
/// 이걸로 override 해야 한다 — 실제 Hive 구현은 파일 IO 라 위젯 테스트의
/// fake async 환경에서 완료되지 않아 보드가 로딩 스피너(무한 애니메이션)에
/// 머물고 pumpAndSettle 이 타임아웃된다.
class FakeBoardConfigRepository implements BoardConfigRepositoryPort {
  FakeBoardConfigRepository({this.stored});

  BoardConfig? stored;
  int saveCount = 0;

  @override
  Future<BoardConfig?> load() async => stored;

  @override
  Future<void> save(BoardConfig config) async {
    stored = config;
    saveCount += 1;
  }
}
