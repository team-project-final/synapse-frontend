import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';

void main() {
  GoRouter loginRouter() {
    return GoRouter(
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
  }

  // ⚠ 현재 로그인 버튼은 개발용 바이패스 적용 중(login_screen._submit).
  // 입력 없이 버튼만 눌러도 repository 호출 없이 인증 상태로 진입한다.
  // 실 로그인 로직 자체는 AuthNotifier.login / AuthRepository 유닛테스트에서 검증한다.
  testWidgets('login bypass authenticates without repository call', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final router = loginRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryPortProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // 입력 없이 버튼만 눌러도 진입(바이패스).
    await tester.tap(find.byType(FilledButton));
    await tester.pump(); // 탭 처리 + 바이패스 상태 반영(성공 인트로 오버레이 삽입)

    expect(repository.loginCallCount, 0);
    expect(find.text('이메일을 입력해주세요'), findsNothing);

    // 인트로 오버레이 시퀀스가 끝나 스스로 제거되도록 충분히 진행(타이머 정리).
    await tester.pump(const Duration(seconds: 3));
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

  GoRouter mfaRouter() {
    return GoRouter(
      initialLocation: AppRoutes.mfa,
      routes: [
        GoRoute(
          path: AppRoutes.mfa,
          builder: (context, state) => const MfaScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) =>
              const Scaffold(body: Text('dashboard-target')),
        ),
      ],
    );
  }

  testWidgets('mfa backup code verifies via API and opens dashboard', (
    tester,
  ) async {
    final api = _FakeMfaApi();
    final router = mfaRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [platformAuthApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.byKey(const Key('mfa-backup-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('백업 코드 입력'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('mfa-backup-code-field')),
      'AAAA-1111',
    );
    await tester.tap(find.byKey(const Key('mfa-backup-verify-button')));
    await tester.pumpAndSettle();

    expect(api.backupCodes, ['AAAA-1111']);
    expect(find.text('dashboard-target'), findsOneWidget);
  });

  testWidgets('mfa wrong code shows error and stays', (tester) async {
    final api = _FakeMfaApi();
    final router = mfaRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [platformAuthApiProvider.overrideWithValue(api)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.byKey(const Key('mfa-backup-toggle')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('mfa-backup-code-field')),
      'WRONG-0000',
    );
    await tester.tap(find.byKey(const Key('mfa-backup-verify-button')));
    await tester.pumpAndSettle();

    expect(find.text('백업 코드가 올바르지 않습니다. 다시 확인해주세요.'), findsOneWidget);
    expect(find.text('dashboard-target'), findsNothing);
  });
}

class _FakeMfaApi extends PlatformAuthApi {
  _FakeMfaApi() : super(Dio());

  final List<String> backupCodes = [];

  @override
  Future<bool> verifyMfa(String code) async => code == '123456';

  @override
  Future<bool> verifyMfaBackupCode(String code) async {
    if (code != 'AAAA-1111') {
      throw const PlatformAuthApiException(
        status: 400,
        code: 'PLAT-003',
        message: 'invalid',
      );
    }
    backupCodes.add(code);
    return true;
  }
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
