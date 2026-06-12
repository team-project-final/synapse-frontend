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
import 'package:synapse_frontend/shared/features/dashboard/providers/board_config_providers.dart';

import 'shared/features/dashboard/board_config_fakes.dart';

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

  testWidgets('login reaches dashboard through app router', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          authRepositoryPortProvider.overrideWithValue(_StubLoginRepository()),
          // 실제 Hive 구현은 파일 IO 라 위젯 테스트에서 완료되지 않아 보드가
          // 로딩 스피너에 머물고 pumpAndSettle 이 타임아웃된다 → fake 필수.
          boardConfigRepositoryProvider.overrideWithValue(
            FakeBoardConfigRepository(),
          ),
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
    // 인트로 오버레이(고정 타이머) 시퀀스가 끝나도록 충분히 진행.
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    // 대시보드 히어로 카피가 AI Tutor 디자인으로 변경됨.
    expect(find.text('무엇을 학습해 볼까요?'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    // 보드가 구성 로드 후 타일을 빌드하며 시작한 dio 호출의 0ms 타이머 드레인
    // (미소진 시 teardown 에서 pending timer 실패).
    await tester.pump(const Duration(milliseconds: 300));
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
          boardConfigRepositoryProvider.overrideWithValue(
            FakeBoardConfigRepository(),
          ),
        ],
        child: const SynapseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);

    // 보드 타일 dio 호출의 0ms 타이머 드레인 (위 테스트와 동일 사유).
    await tester.pump(const Duration(milliseconds: 300));
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

class _StubLoginRepository implements AuthRepositoryPort {
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
    return const AuthTokens(accessToken: 'stub-access');
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
