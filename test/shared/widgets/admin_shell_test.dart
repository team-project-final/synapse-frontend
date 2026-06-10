import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/shared/widgets/admin_shell.dart';

void main() {
  Future<_FakeAuthRepository> pumpShell(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeAuthRepository();
    final router = GoRouter(
      initialLocation: AppRoutes.admin,
      routes: [
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.admin,
              builder: (context, state) => const Text('admin-content'),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Scaffold(body: Text('login')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryPortProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('로그아웃 메뉴 선택 시 세션을 정리한다', (tester) async {
    final repository = await pumpShell(tester);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();

    expect(repository.logoutCallCount, 1);
  });

  testWidgets('환경 전환 드롭다운(미지원 기능)은 노출하지 않는다', (tester) async {
    await pumpShell(tester);

    expect(find.byType(DropdownButton<String>), findsNothing);
    expect(find.text('admin-content'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepositoryPort {
  int logoutCallCount = 0;

  @override
  Future<AuthTokens?> restoreSession() async => null;

  @override
  Future<AuthTokens> completeOAuthLogin({required String accessToken}) async {
    return AuthTokens(accessToken: accessToken);
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    return const AuthTokens(accessToken: 'access');
  }

  @override
  Future<void> signup({
    required String email,
    required String password,
  }) async {}

  @override
  void loginWithOAuth(String provider) {}

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }
}
