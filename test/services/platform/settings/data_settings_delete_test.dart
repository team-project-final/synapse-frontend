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
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountApiProvider.overrideWithValue(accountApi),
          authRepositoryPortProvider.overrideWithValue(authPort),
        ],
        child: const MaterialApp(home: Scaffold(body: DataSettingsScreen())),
      ),
    );
  }

  testWidgets('계정 삭제 확인 시 삭제 API 호출 후 로그아웃한다', (tester) async {
    final authPort = FakeAuthPort();
    final accountApi = FakeAccountApi();
    await pump(tester, accountApi: accountApi, authPort: authPort);

    await tester.tap(find.widgetWithText(FilledButton, '계정 삭제'));
    await tester.pumpAndSettle();
    // 확인 다이얼로그의 '삭제' 확정
    await tester.tap(find.widgetWithText(FilledButton, '삭제'));
    await tester.pumpAndSettle();

    expect(accountApi.deleteAccountCount, 1);
    expect(authPort.logoutCalled, isTrue);
    expect(find.text('계정이 삭제되었습니다.'), findsOneWidget);
  });

  testWidgets('다이얼로그에서 취소하면 삭제하지 않는다', (tester) async {
    final authPort = FakeAuthPort();
    final accountApi = FakeAccountApi();
    await pump(tester, accountApi: accountApi, authPort: authPort);

    await tester.tap(find.widgetWithText(FilledButton, '계정 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '취소'));
    await tester.pumpAndSettle();

    expect(accountApi.deleteAccountCount, 0);
    expect(authPort.logoutCalled, isFalse);
  });

  testWidgets('삭제 API 실패 시 에러 메시지를 보여주고 로그아웃하지 않는다', (tester) async {
    final authPort = FakeAuthPort();
    final accountApi = FakeAccountApi(
      deleteAccountError: const AccountApiException(
        status: 500,
        message: '계정 삭제에 실패했습니다.',
      ),
    );
    await pump(tester, accountApi: accountApi, authPort: authPort);

    await tester.tap(find.widgetWithText(FilledButton, '계정 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '삭제'));
    await tester.pumpAndSettle();

    expect(accountApi.deleteAccountCount, 1);
    expect(authPort.logoutCalled, isFalse);
    expect(find.text('계정 삭제에 실패했습니다.'), findsOneWidget);
  });
}
