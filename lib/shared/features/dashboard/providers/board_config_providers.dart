import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/features/dashboard/data/hive_board_config_repository.dart';
import 'package:synapse_frontend/shared/features/dashboard/domain/board_config.dart';

final boardConfigRepositoryProvider = Provider<BoardConfigRepositoryPort>(
  (ref) => const HiveBoardConfigRepository(),
);

/// 보드 구성 상태. 시작 시 디바이스 저장값 로드(없으면 [BoardConfig.defaults]),
/// [BoardConfigNotifier.add]/[BoardConfigNotifier.remove] 는 화면 즉시 반영,
/// [BoardConfigNotifier.apply]('완료' 버튼)에서만 디바이스에 저장한다.
final boardConfigProvider =
    AsyncNotifierProvider<BoardConfigNotifier, BoardConfig>(
      BoardConfigNotifier.new,
    );

class BoardConfigNotifier extends AsyncNotifier<BoardConfig> {
  @override
  Future<BoardConfig> build() async {
    final BoardConfig? stored = await ref
        .watch(boardConfigRepositoryProvider)
        .load();
    return stored ?? BoardConfig.defaults;
  }

  BoardConfig get _current => state.asData?.value ?? BoardConfig.defaults;

  void remove(String id) => state = AsyncData<BoardConfig>(
    _current.copyWithout(id),
  );

  void add(String id) => state = AsyncData<BoardConfig>(
    _current.copyWithAdded(id),
  );

  /// '완료' 시 호출 — 현재 구성을 디바이스에 저장.
  Future<void> apply() async {
    final BoardConfig? config = state.asData?.value;
    if (config == null) return;
    await ref.read(boardConfigRepositoryProvider).save(config);
  }
}
