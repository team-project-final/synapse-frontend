import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/shared/features/dashboard/domain/board_config.dart';
import 'package:synapse_frontend/shared/features/dashboard/presentation/widgets/home_board_section.dart';
import 'package:synapse_frontend/shared/features/dashboard/providers/board_config_providers.dart';

import 'board_config_fakes.dart';

void main() {
  group('BoardConfigNotifier', () {
    test('저장값이 없으면 defaults 를 노출한다', () async {
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          boardConfigRepositoryProvider.overrideWithValue(
            FakeBoardConfigRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final config = await container.read(boardConfigProvider.future);

      expect(config, BoardConfig.defaults);
    });

    test('저장값이 있으면 그 구성(순서 포함)을 복원한다', () async {
      final repository = FakeBoardConfigRepository(
        stored: const BoardConfig(widgetIds: ['streak', 'ask']),
      );
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          boardConfigRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final config = await container.read(boardConfigProvider.future);

      expect(config.widgetIds, ['streak', 'ask']);
    });

    test('remove/add 는 상태를 즉시 바꾸고, 중복 add 는 무시한다', () async {
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          boardConfigRepositoryProvider.overrideWithValue(
            FakeBoardConfigRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(boardConfigProvider.future);
      final notifier = container.read(boardConfigProvider.notifier);

      notifier.remove('ask');
      expect(
        container.read(boardConfigProvider).requireValue.widgetIds,
        isNot(contains('ask')),
      );

      notifier.add('ask');
      notifier.add('ask');
      final ids = container.read(boardConfigProvider).requireValue.widgetIds;
      expect(ids.where((id) => id == 'ask'), hasLength(1));
      expect(ids.last, 'ask'); // 재추가는 맨 뒤에 붙는다
    });

    test('apply 시점에만 저장된다', () async {
      final repository = FakeBoardConfigRepository();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          boardConfigRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container.read(boardConfigProvider.future);
      final notifier = container.read(boardConfigProvider.notifier);

      notifier.remove('ranking');
      expect(repository.saveCount, 0); // 제거만으로는 저장 안 됨

      await notifier.apply();

      expect(repository.saveCount, 1);
      expect(repository.stored?.widgetIds, isNot(contains('ranking')));
    });
  });

  group('HomeBoardSection 영속화', () {
    // 타일 내부 콘텐츠가 learning 통계 provider 를 watch 하므로(테스트에선
    // 네트워크 불가 → AsyncError placeholder) retry 를 꺼서 타이머 누수를 막는다.
    Future<ProviderContainer> pumpBoard(
      WidgetTester tester,
      BoardConfigRepositoryPort repository,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          boardConfigRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: HomeBoardSection()),
          ),
        ),
      );
      // 두 번 pump: 1) 구성 로드 완료 → 타일 빌드, 2) 타일이 시작한 dio 호출의
      // 0ms 타이머 드레인(미소진 시 teardown 에서 pending timer 실패).
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      return container;
    }

    testWidgets('로드 완료 전에는 보드 대신 로딩 인디케이터를 보여준다', (tester) async {
      // 로드가 끝나기 전까지 디폴트 구성이 노출되면 안 된다(구성 점프 깜빡임).
      final repository = _DelayedBoardConfigRepository(
        stored: const BoardConfig(widgetIds: ['streak']),
      );
      await pumpBoard(tester, repository);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('내 보드'), findsNothing);
      expect(find.text('오늘 복습'), findsNothing);

      repository.completer.complete();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100)); // 타일 dio 타이머 드레인

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('스트릭'), findsOneWidget);
    });

    testWidgets('저장된 구성만 렌더링한다', (tester) async {
      final repository = FakeBoardConfigRepository(
        stored: const BoardConfig(widgetIds: ['streak']),
      );
      await pumpBoard(tester, repository);

      expect(find.text('스트릭'), findsOneWidget);
      expect(find.text('오늘 복습'), findsNothing);
    });

    testWidgets('저장된 모르는 위젯 id 는 조용히 무시한다', (tester) async {
      final repository = FakeBoardConfigRepository(
        stored: const BoardConfig(widgetIds: ['removedInV2', 'streak']),
      );
      await pumpBoard(tester, repository);

      expect(tester.takeException(), isNull);
      expect(find.text('스트릭'), findsOneWidget);
    });

    testWidgets('편집 → 제거 → 완료 시 구성이 저장된다', (tester) async {
      final repository = FakeBoardConfigRepository();
      await pumpBoard(tester, repository);

      await tester.tap(find.text('편집'));
      await tester.pump();

      // 첫 타일(ask)의 제거(×) 핸들 탭.
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();

      await tester.tap(find.text('완료'));
      await tester.pump();

      expect(repository.saveCount, 1);
      expect(repository.stored?.widgetIds, isNot(contains('ask')));
      expect(
        repository.stored?.widgetIds,
        BoardConfig.defaults.widgetIds.where((id) => id != 'ask').toList(),
      );
    });
  });
}

/// load 가 [completer] 완료 전까지 끝나지 않는 fake — 로딩 상태 검증용.
class _DelayedBoardConfigRepository implements BoardConfigRepositoryPort {
  _DelayedBoardConfigRepository({this.stored});

  final BoardConfig? stored;
  final Completer<void> completer = Completer<void>();

  @override
  Future<BoardConfig?> load() async {
    await completer.future;
    return stored;
  }

  @override
  Future<void> save(BoardConfig config) async {}
}

