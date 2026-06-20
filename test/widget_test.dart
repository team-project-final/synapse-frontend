import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/app.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/router/app_router.dart';
import 'package:synapse_frontend/core/services/service_boundary.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/auth_repository.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';

void main() {
  testWidgets('unauthenticated user sees login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          authRepositoryPortProvider.overrideWith(
            (ref) => ref.watch(authRepositoryProvider),
          ),
        ],
        child: const SynapseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('로그인'), findsWidgets);
  });

  testWidgets('API-backed login reaches dashboard through app router', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          authRepositoryPortProvider.overrideWithValue(repository),
        ],
        child: const SynapseApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'P@ssw0rd!');
    await tester.tap(find.widgetWithText(FilledButton, '로그인'));
    await tester.pumpAndSettle();

    expect(repository.loginCallCount, 1);
    expect(find.text('무엇을 학습해 볼까요?'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('stored tokens restore authenticated session', (tester) async {
    final tokenStore = InMemoryTokenStore();
    await tokenStore.save(const AuthTokens(accessToken: 'stored-access'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(tokenStore),
          authRepositoryPortProvider.overrideWith(
            (ref) => ref.watch(authRepositoryProvider),
          ),
        ],
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
        overrides: [
          tokenStoreProvider.overrideWithValue(tokenStore),
          authRepositoryPortProvider.overrideWith(
            (ref) => ref.watch(authRepositoryProvider),
          ),
        ],
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
  Future<void> migrateLegacyStorage() async {}

  @override
  Future<AuthTokens?> read() => completer.future;

  @override
  Future<void> save(AuthTokens tokens) async {}

  @override
  Future<void> clear() async {}
}

class _FakeAuthRepository implements AuthRepositoryPort {
  int loginCallCount = 0;

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
    loginCallCount += 1;
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
  Future<void> logout() async {}
}
