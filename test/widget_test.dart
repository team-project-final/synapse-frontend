import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/app.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/router/app_router.dart';
import 'package:synapse_frontend/core/services/service_boundary.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';

void main() {
  testWidgets('unauthenticated user sees login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(InMemoryTokenStore())],
        child: const SynapseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('로그인'), findsWidgets);
  });

  testWidgets('stored tokens restore authenticated session', (tester) async {
    final tokenStore = InMemoryTokenStore();
    await tokenStore.save(
      const AuthTokens(
        accessToken: 'stored-access',
        refreshToken: 'stored-refresh',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(tokenStore)],
        child: const SynapseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('startup restore shows bootstrap state instead of login', (
    tester,
  ) async {
    final tokenStore = _DelayedTokenStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(tokenStore)],
        child: const SynapseApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    tokenStore.completer.complete(null);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  test('should register representative domain routes', () {
    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(() => _AuthenticatedNotifier()),
      ],
    );
    addTearDown(container.dispose);
    final appRouter = container.read(appRouterProvider);

    const paths = [
      AppRoutes.login,
      AppRoutes.notes,
      AppRoutes.decks,
      AppRoutes.graph,
      AppRoutes.communityGroups,
      AppRoutes.notifications,
    ];

    for (final path in paths) {
      final matches = appRouter.configuration.findMatch(Uri.parse(path));
      expect(matches.isError, isFalse, reason: path);
      expect(matches.matches, isNotEmpty, reason: path);
    }
  });

  test('should group domains by four backend service boundaries', () {
    expect(ServiceBoundary.values, hasLength(4));
    expect(
      ServiceBoundary.platform.domains,
      containsAll(['auth', 'billing', 'notifications']),
    );
    expect(
      ServiceBoundary.engagement.domains,
      containsAll(['community', 'gamification']),
    );
    expect(
      ServiceBoundary.knowledge.domains,
      containsAll(['notes', 'graph', 'search']),
    );
    expect(ServiceBoundary.learning.domains, contains('cards'));
  });
}

class _AuthenticatedNotifier extends AuthNotifier {
  @override
  AuthState build() =>
      const AuthState(status: AuthStatus.authenticated, accessToken: 'test');
}

class _DelayedTokenStore implements TokenStore {
  final completer = Completer<AuthTokens?>();

  @override
  Future<AuthTokens?> read() => completer.future;

  @override
  Future<void> save(AuthTokens tokens) async {}

  @override
  Future<void> clear() async {}
}
