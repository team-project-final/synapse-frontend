import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_repository_exception.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';

void main() {
  testWidgets('login bypass does not call repository and opens dashboard', (
    tester,
  ) async {
    final repository = _FakeAuthRepository()
      ..loginError = const AuthRepositoryException(
        status: 401,
        code: 'PLAT-009-002',
        detail: 'Invalid credentials',
      );
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) =>
              const Scaffold(body: Text('dashboard-target')),
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

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'P@ssw0rd!');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(repository.loginCallCount, 0);
    expect(find.text('dashboard-target'), findsOneWidget);
  });

  testWidgets('login bypasses validation and opens dashboard in early dev', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) =>
              const Scaffold(body: Text('dashboard-target')),
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

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('dashboard-target'), findsOneWidget);
  });

  testWidgets('signup rejects password without a digit', (tester) async {
    await tester.pumpWidget(
      _app(repository: _FakeAuthRepository(), child: const SignupScreen()),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Password!');
    await tester.enterText(find.byType(TextFormField).at(2), 'Password!');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Password must include a number.'), findsOneWidget);
  });

  testWidgets('signup rejects password without a special character', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeAuthRepository(), child: const SignupScreen()),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1');
    await tester.enterText(find.byType(TextFormField).at(2), 'Password1');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(
      find.text('Password must include a special character.'),
      findsOneWidget,
    );
  });

  testWidgets('signup rejects mismatched confirmation', (tester) async {
    await tester.pumpWidget(
      _app(repository: _FakeAuthRepository(), child: const SignupScreen()),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'P@ssw0rd!');
    await tester.enterText(find.byType(TextFormField).at(2), 'P@ssw0rd2!');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('signup success shows SnackBar and navigates to login', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final router = GoRouter(
      initialLocation: AppRoutes.signup,
      routes: [
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) =>
              const Scaffold(body: Text('login-target')),
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

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'P@ssw0rd!');
    await tester.enterText(find.byType(TextFormField).at(2), 'P@ssw0rd!');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    expect(repository.signupCallCount, 1);
    expect(find.text('Signup completed. Please log in.'), findsOneWidget);
    expect(find.text('login-target'), findsOneWidget);
  });
}

Widget _app({required AuthRepositoryPort repository, required Widget child}) {
  return ProviderScope(
    overrides: [authRepositoryPortProvider.overrideWithValue(repository)],
    child: MaterialApp(home: child),
  );
}

class _FakeAuthRepository implements AuthRepositoryPort {
  Object? loginError;
  Object? signupError;
  int loginCallCount = 0;
  int signupCallCount = 0;

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
    final error = loginError;
    if (error != null) throw error;
    return const AuthTokens(accessToken: 'access');
  }

  @override
  Future<void> signup({required String email, required String password}) async {
    signupCallCount += 1;
    final error = signupError;
    if (error != null) throw error;
  }

  @override
  void loginWithOAuth(String provider) {}

  @override
  Future<void> logout() async {}
}
