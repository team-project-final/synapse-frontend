import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/auth_repository.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/oauth_callback_screen.dart';

void main() {
  // #25에서 AppRoutes.authCallback 상수가 제거됨. 콜백 화면 위젯은 유지되므로
  // 경로 리터럴로 self-contained 라우터를 구성해 위젯 동작만 검증한다.
  const authCallbackPath = '/auth/callback';

  testWidgets('oauth callback stores access token and navigates to dashboard', (
    tester,
  ) async {
    final tokenStore = InMemoryTokenStore();
    final router = GoRouter(
      initialLocation: '$authCallbackPath?access_token=access',
      routes: [
        GoRoute(
          path: authCallbackPath,
          builder: (context, state) => OAuthCallbackScreen(
            accessToken: state.uri.queryParameters['access_token'],
            error: state.uri.queryParameters['error'],
          ),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const Text('dashboard'),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Text('login'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(tokenStore),
          authRepositoryPortProvider.overrideWith(
            (ref) => ref.watch(authRepositoryProvider),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final tokens = await tokenStore.read();
    expect(tokens?.accessToken, 'access');
    expect(find.text('dashboard'), findsOneWidget);
  });

  testWidgets('oauth callback with error navigates to login', (tester) async {
    final tokenStore = InMemoryTokenStore();
    final router = GoRouter(
      initialLocation: '$authCallbackPath?error=denied',
      routes: [
        GoRoute(
          path: authCallbackPath,
          builder: (context, state) => OAuthCallbackScreen(
            accessToken: state.uri.queryParameters['access_token'],
            error: state.uri.queryParameters['error'],
          ),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const Text('dashboard'),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Text('login'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(tokenStore),
          authRepositoryPortProvider.overrideWith(
            (ref) => ref.watch(authRepositoryProvider),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(await tokenStore.read(), isNull);
    expect(find.text('login'), findsOneWidget);
  });
}
