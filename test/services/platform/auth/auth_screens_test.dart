import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_repository_exception.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';

void main() {
  testWidgets('login calls repository and opens dashboard on success', (
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

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'P@ssw0rd!');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(repository.loginCallCount, 1);
    expect(find.text('dashboard-target'), findsOneWidget);
  });

  testWidgets('login validates form before calling repository', (tester) async {
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

    expect(repository.loginCallCount, 0);
    expect(find.text('이메일을 입력해주세요'), findsOneWidget);
    expect(find.text('비밀번호는 8자 이상이어야 합니다'), findsOneWidget);
    expect(find.text('dashboard-target'), findsNothing);
  });

  testWidgets('login failure displays repository detail', (tester) async {
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

    expect(repository.loginCallCount, 1);
    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(find.text('dashboard-target'), findsNothing);
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

  testWidgets('password reset calls platform API and returns to login', (
    tester,
  ) async {
    final api = _FakePlatformAuthApi();
    final router = GoRouter(
      initialLocation: AppRoutes.passwordReset,
      routes: [
        GoRoute(
          path: AppRoutes.passwordReset,
          builder: (context, state) => const PasswordResetScreen(),
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
        overrides: [platformAuthApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('password-reset-email-field')),
      'user@example.com',
    );
    await tester.tap(find.byKey(const Key('password-reset-continue-button-0')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('password-reset-code-field')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('password-reset-continue-button-1')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('password-reset-new-password-field')),
      'N3wP@ssword!',
    );
    await tester.enterText(
      find.byKey(const Key('password-reset-confirm-password-field')),
      'N3wP@ssword!',
    );
    await tester.tap(find.byKey(const Key('password-reset-continue-button-2')));
    await tester.pumpAndSettle();

    expect(api.requestedEmail, 'user@example.com');
    expect(api.verifiedEmail, 'user@example.com');
    expect(api.verifiedCode, '123456');
    expect(api.confirmedResetToken, 'reset-token');
    expect(api.confirmedPassword, 'N3wP@ssword!');
    expect(find.text('login-target'), findsOneWidget);
  });

  testWidgets('mfa screen verifies backup code through platform API', (
    tester,
  ) async {
    final api = _FakePlatformAuthApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [platformAuthApiProvider.overrideWithValue(api)],
        child: const MaterialApp(home: MfaScreen()),
      ),
    );

    await tester.tap(find.text('백업 코드 사용'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('mfa-backup-code-field')),
      'ABCD-EFGH',
    );
    await tester.tap(find.byKey(const Key('mfa-backup-verify-button')));
    await tester.pump();
    await tester.pump();

    expect(api.verifiedBackupCode, 'ABCD-EFGH');
    expect(find.text('백업 코드 인증이 완료되었습니다. 다시 로그인해 주세요.'), findsOneWidget);
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

class _FakePlatformAuthApi extends PlatformAuthApi {
  _FakePlatformAuthApi() : super(Dio());

  String? requestedEmail;
  String? verifiedEmail;
  String? verifiedCode;
  String? verifiedBackupCode;
  String? confirmedResetToken;
  String? confirmedPassword;

  @override
  Future<bool> requestPasswordReset(String email) async {
    requestedEmail = email;
    return true;
  }

  @override
  Future<PasswordResetVerification> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    verifiedEmail = email;
    verifiedCode = code;
    return PasswordResetVerification(
      resetToken: 'reset-token',
      expiresAt: DateTime.utc(2026, 6, 21, 9, 30),
    );
  }

  @override
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    confirmedResetToken = resetToken;
    confirmedPassword = newPassword;
  }

  @override
  Future<bool> verifyMfaBackupCode(String code) async {
    verifiedBackupCode = code;
    return true;
  }
}
