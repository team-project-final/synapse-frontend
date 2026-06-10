import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/services/platform/features/settings/data/account_api.dart';
import 'package:synapse_frontend/services/platform/features/settings/presentation/screens/settings_screens.dart';

import 'account_api_fakes.dart';

void main() {
  Future<void> pump(WidgetTester tester, FakeAccountApi accountApi) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountApiProvider.overrideWithValue(accountApi),
          authRepositoryPortProvider.overrideWithValue(FakeAuthPort()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ProfileSettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('프로필을 로드해 이름·이메일·언어를 표시한다', (tester) async {
    await pump(
      tester,
      FakeAccountApi(
        profile: const UserProfile(
          id: 'u',
          hasPassword: true,
          email: 'hong@example.com',
          displayName: '홍길동',
          language: 'en-US',
        ),
      ),
    );

    expect(find.text('홍길동'), findsOneWidget);
    expect(find.text('hong@example.com'), findsOneWidget);
    // 언어 코드 en-US → 드롭다운 표시값 English
    expect(find.text('English'), findsWidgets);
  });

  testWidgets('저장 시 표시 이름과 언어 코드로 updateProfile을 호출한다', (tester) async {
    final accountApi = FakeAccountApi(
      profile: const UserProfile(
        id: 'u',
        hasPassword: true,
        email: 'hong@example.com',
        displayName: '홍길동',
        language: 'ko-KR',
      ),
    );
    await pump(tester, accountApi);

    await tester.enterText(find.byType(TextFormField).first, '김철수');
    await tester.tap(find.widgetWithText(FilledButton, '저장'));
    await tester.pumpAndSettle();

    expect(accountApi.updatedDisplayName, '김철수');
    expect(accountApi.updatedLanguage, 'ko-KR');
    expect(find.text('프로필이 저장되었습니다.'), findsOneWidget);
  });

  testWidgets('표시 이름이 비어 있으면 저장하지 않고 검증 에러를 보여준다', (tester) async {
    final accountApi = FakeAccountApi(
      profile: const UserProfile(
        id: 'u',
        hasPassword: true,
        email: 'hong@example.com',
        displayName: '홍길동',
        language: 'ko-KR',
      ),
    );
    await pump(tester, accountApi);

    await tester.enterText(find.byType(TextFormField).first, '   ');
    await tester.tap(find.widgetWithText(FilledButton, '저장'));
    await tester.pump();

    expect(find.text('표시 이름을 입력해주세요.'), findsOneWidget);
    expect(accountApi.updatedDisplayName, isNull);
  });
}
