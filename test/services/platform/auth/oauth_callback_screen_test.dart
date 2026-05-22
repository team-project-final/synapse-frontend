import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/oauth_callback_screen.dart';

void main() {
  testWidgets('oauth callback stores tokens and navigates to dashboard', (
    tester,
  ) async {
    final tokenStore = InMemoryTokenStore();
    final router = GoRouter(
      initialLocation:
          '${AppRoutes.authCallback}?access_token=access&refresh_token=refresh',
      routes: [
        GoRoute(
          path: AppRoutes.authCallback,
          builder: (context, state) => OAuthCallbackScreen(
            accessToken: state.uri.queryParameters['access_token'],
            refreshToken: state.uri.queryParameters['refresh_token'],
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
        overrides: [tokenStoreProvider.overrideWithValue(tokenStore)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final tokens = await tokenStore.read();
    expect(tokens?.accessToken, 'access');
    expect(tokens?.refreshToken, 'refresh');
    expect(find.text('dashboard'), findsOneWidget);
  });

  testWidgets('oauth callback with error navigates to login', (tester) async {
    final tokenStore = InMemoryTokenStore();
    final router = GoRouter(
      initialLocation: '${AppRoutes.authCallback}?error=denied',
      routes: [
        GoRoute(
          path: AppRoutes.authCallback,
          builder: (context, state) => OAuthCallbackScreen(
            accessToken: state.uri.queryParameters['access_token'],
            refreshToken: state.uri.queryParameters['refresh_token'],
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
        overrides: [tokenStoreProvider.overrideWithValue(tokenStore)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(await tokenStore.read(), isNull);
    expect(find.text('login'), findsOneWidget);
  });
}
