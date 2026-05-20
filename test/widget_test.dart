import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/app.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/core/router/app_router.dart';
import 'package:synapse_frontend/core/services/service_boundary.dart';

void main() {
  testWidgets('unauthenticated user sees login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SynapseApp()));
    await tester.pumpAndSettle();

    expect(find.text('로그인'), findsWidgets);
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
