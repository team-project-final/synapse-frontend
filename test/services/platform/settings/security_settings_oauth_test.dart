import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/services/platform/features/settings/data/account_api.dart';
import 'package:synapse_frontend/services/platform/features/settings/presentation/screens/settings_screens.dart';

import 'account_api_fakes.dart';

void main() {
  Future<void> pump(WidgetTester tester, FakeAccountApi accountApi) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountApiProvider.overrideWithValue(accountApi),
          authRepositoryPortProvider.overrideWithValue(FakeAuthPort()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SecuritySettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('연결된 계정 목록을 로드해 표시한다', (tester) async {
    await pump(
      tester,
      FakeAccountApi(
        profile: const UserProfile(id: 'u', hasPassword: true),
        connections: const [
          OAuthConnection(provider: 'google', email: 'u@gmail.com'),
        ],
      ),
    );

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('u@gmail.com'), findsOneWidget);
  });

  testWidgets('연결 해제 성공 시 unlink API를 호출하고 안내를 보여준다', (tester) async {
    final accountApi = FakeAccountApi(
      profile: const UserProfile(id: 'u', hasPassword: true),
      connections: const [
        OAuthConnection(provider: 'google', email: 'u@gmail.com'),
      ],
    );
    await pump(tester, accountApi);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, '연결 해제'));
    await tester.tap(find.widgetWithText(OutlinedButton, '연결 해제'));
    await tester.pumpAndSettle();

    expect(accountApi.unlinkedProviders, ['google']);
    expect(find.text('Google 연결을 해제했습니다.'), findsOneWidget);
  });

  testWidgets('마지막 로그인 수단이면 해제 버튼이 비활성화되고 안내가 표시된다', (tester) async {
    await pump(
      tester,
      FakeAccountApi(
        profile: const UserProfile(id: 'u', hasPassword: false),
        connections: const [
          OAuthConnection(provider: 'google', email: 'u@gmail.com'),
        ],
      ),
    );

    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, '연결 해제'),
    );
    expect(button.onPressed, isNull);
    expect(
      find.text('마지막 로그인 수단은 해제할 수 없습니다. 비밀번호를 먼저 설정하세요.'),
      findsOneWidget,
    );
  });

  testWidgets('해제가 서버에서 거부되면 에러 메시지를 보여준다', (tester) async {
    final accountApi = FakeAccountApi(
      profile: const UserProfile(id: 'u', hasPassword: true),
      connections: const [
        OAuthConnection(provider: 'google', email: 'u@gmail.com'),
      ],
      unlinkError: const AccountApiException(
        status: 400,
        code: 'PLAT-OAUTH-002',
        message: '마지막 로그인 수단은 해제할 수 없습니다.',
      ),
    );
    await pump(tester, accountApi);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, '연결 해제'));
    await tester.tap(find.widgetWithText(OutlinedButton, '연결 해제'));
    await tester.pumpAndSettle();

    expect(accountApi.unlinkedProviders, isEmpty);
    expect(find.text('마지막 로그인 수단은 해제할 수 없습니다.'), findsWidgets);
  });
}
