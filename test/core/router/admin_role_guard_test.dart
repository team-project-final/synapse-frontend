import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/router/app_router.dart';
import 'package:synapse_frontend/shared/features/dashboard/providers/board_config_providers.dart';

import '../../shared/features/dashboard/board_config_fakes.dart';

void main() {
  testWidgets('비관리자는 /admin 접근 시 대시보드로 리다이렉트된다', (tester) async {
    final container = ProviderContainer(
      // 이 테스트는 라우터 리다이렉트만 검증한다. 대시보드로 리다이렉트되며
      // 마운트되는 데이터 provider의 네트워크 호출이 테스트에서 실패하면
      // Riverpod 3 기본 자동 retry 타이머가 teardown 이후까지 남아(pending timer)
      // 테스트가 깨졌다. 라우팅 검증에는 retry가 불필요하므로 끈다.
      retry: (_, _) => null,
      overrides: [
        authNotifierProvider.overrideWith(() => _RoleNotifier(const [])),
        // 실제 Hive 구현은 파일 IO 라 위젯 테스트에서 완료되지 않아 보드가
        // 로딩 스피너에 머물고 pumpAndSettle 이 타임아웃된다 → fake 필수.
        boardConfigRepositoryProvider.overrideWithValue(
          FakeBoardConfigRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    router.go(AppRoutes.adminUsers);
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.dashboard,
    );

    // 대시보드 보드가 구성 로드 후 타일을 빌드하며 시작한 dio 호출의 0ms
    // 타이머를 드레인한다(미소진 시 teardown 에서 pending timer 실패).
    await tester.pump(const Duration(milliseconds: 300));
  });
}

class _RoleNotifier extends AuthNotifier {
  _RoleNotifier(this._roles);

  final List<String> _roles;

  @override
  AuthState build() => AuthState(
    status: AuthStatus.authenticated,
    accessToken: 'test',
    roles: _roles,
  );
}
