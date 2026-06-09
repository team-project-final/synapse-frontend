import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/services/platform/features/settings/data/account_api.dart';
import 'package:synapse_frontend/services/platform/features/settings/presentation/screens/settings_screens.dart';

import 'account_api_fakes.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required FakeAccountApi accountApi,
    required FakeAuthPort authPort,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountApiProvider.overrideWithValue(accountApi),
          authRepositoryPortProvider.overrideWithValue(authPort),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SecuritySettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillPasswords(
    WidgetTester tester, {
    required String current,
    required String next,
    required String confirm,
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), current);
    await tester.enterText(fields.at(1), next);
    await tester.enterText(fields.at(2), confirm);
  }

  testWidgets('비밀번호 변경 성공 시 로그아웃되고 안내 메시지를 보여준다', (tester) async {
    final authPort = FakeAuthPort();
    final accountApi = FakeAccountApi();
    await pump(tester, accountApi: accountApi, authPort: authPort);

    await fillPasswords(
      tester,
      current: 'OldPass1!',
      next: 'NewPass1!',
      confirm: 'NewPass1!',
    );
    await tester.tap(find.widgetWithText(OutlinedButton, '변경'));
    await tester.pumpAndSettle();

    expect(accountApi.changePasswordCount, 1);
    expect(find.text('비밀번호가 변경되었습니다. 다시 로그인해주세요.'), findsOneWidget);
    expect(authPort.logoutCalled, isTrue);
  });

  testWidgets('현재 비밀번호가 틀리면 에러 메시지를 보여주고 로그아웃하지 않는다', (tester) async {
    final authPort = FakeAuthPort();
    await pump(
      tester,
      accountApi: FakeAccountApi(
        changePasswordError: const AccountApiException(
          status: 400,
          code: 'PLAT-USER-002',
          message: '현재 비밀번호가 올바르지 않습니다.',
        ),
      ),
      authPort: authPort,
    );

    await fillPasswords(
      tester,
      current: 'WrongPass1!',
      next: 'NewPass1!',
      confirm: 'NewPass1!',
    );
    await tester.tap(find.widgetWithText(OutlinedButton, '변경'));
    await tester.pumpAndSettle();

    expect(find.text('현재 비밀번호가 올바르지 않습니다.'), findsOneWidget);
    expect(authPort.logoutCalled, isFalse);
  });

  testWidgets('새 비밀번호 확인이 다르면 API 호출 없이 검증 에러를 보여준다', (tester) async {
    final accountApi = FakeAccountApi();
    await pump(tester, accountApi: accountApi, authPort: FakeAuthPort());

    await fillPasswords(
      tester,
      current: 'OldPass1!',
      next: 'NewPass1!',
      confirm: 'Mismatch1!',
    );
    await tester.tap(find.widgetWithText(OutlinedButton, '변경'));
    await tester.pump();

    expect(find.text('새 비밀번호가 일치하지 않습니다.'), findsOneWidget);
    expect(accountApi.changePasswordCount, 0);
  });
}
