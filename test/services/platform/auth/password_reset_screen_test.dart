import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse_frontend/core/constants/app_routes.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';

void main() {
  Future<GoRouter> pumpScreen(
    WidgetTester tester,
    _FakePlatformAuthApi api,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    return router;
  }

  // Stepper는 모든 step의 controls를 트리에 갖고 있으므로
  // 활성 step(index)의 버튼을 골라 탭한다.
  Future<void> tapContinue(WidgetTester tester, int step, String label) async {
    final button = find.widgetWithText(FilledButton, label).at(step);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('completes 3-step reset flow and navigates to login', (
    tester,
  ) async {
    final api = _FakePlatformAuthApi();
    await pumpScreen(tester, api);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tapContinue(tester, 0, '다음');
    expect(api.requestedEmail, 'user@example.com');

    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tapContinue(tester, 1, '다음');
    expect(api.verifiedCode, '123456');

    await tester.enterText(find.byType(TextFormField).at(2), 'P@ssw0rd!');
    await tester.enterText(find.byType(TextFormField).at(3), 'P@ssw0rd!');
    await tapContinue(tester, 2, '비밀번호 변경');

    expect(api.confirmedToken, 'reset-token');
    expect(api.confirmedPassword, 'P@ssw0rd!');
    expect(find.text('login-target'), findsOneWidget);
  });

  testWidgets('shows error and stays on code step when verify fails', (
    tester,
  ) async {
    final api = _FakePlatformAuthApi()
      ..verifyError = const PlatformAuthApiException(
        status: 400,
        code: 'PLAT-AUTH-070',
        message: '인증 코드가 올바르지 않거나 만료되었습니다. 처음부터 다시 시도해주세요.',
      );
    await pumpScreen(tester, api);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tapContinue(tester, 0, '다음');

    await tester.enterText(find.byType(TextFormField).at(1), '000000');
    await tapContinue(tester, 1, '다음');

    expect(
      find.text('인증 코드가 올바르지 않거나 만료되었습니다. 처음부터 다시 시도해주세요.'),
      findsOneWidget,
    );
    expect(api.confirmedToken, isNull);
    expect(find.text('login-target'), findsNothing);
  });

  testWidgets('rejects weak password before calling confirm', (tester) async {
    final api = _FakePlatformAuthApi();
    await pumpScreen(tester, api);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tapContinue(tester, 0, '다음');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tapContinue(tester, 1, '다음');

    await tester.enterText(find.byType(TextFormField).at(2), 'password1!');
    await tester.enterText(find.byType(TextFormField).at(3), 'password1!');
    await tester.enterText(find.byType(TextFormField).at(2), 'abcdefgh');
    await tester.enterText(find.byType(TextFormField).at(3), 'abcdefgh');
    await tapContinue(tester, 2, '비밀번호 변경');

    expect(find.text('숫자를 포함해야 합니다'), findsOneWidget);
    expect(api.confirmedToken, isNull);
  });
}

class _FakePlatformAuthApi extends PlatformAuthApi {
  _FakePlatformAuthApi() : super(Dio());

  String? requestedEmail;
  String? verifiedCode;
  String? confirmedToken;
  String? confirmedPassword;
  PlatformAuthApiException? verifyError;

  @override
  Future<void> requestPasswordReset(String email) async {
    requestedEmail = email;
  }

  @override
  Future<PasswordResetVerifyResult> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    final error = verifyError;
    if (error != null) throw error;
    verifiedCode = code;
    return const PasswordResetVerifyResult(resetToken: 'reset-token');
  }

  @override
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    confirmedToken = resetToken;
    confirmedPassword = newPassword;
  }
}
