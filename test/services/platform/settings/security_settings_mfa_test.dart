import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/platform_auth_api.dart';
import 'package:synapse_frontend/services/platform/features/settings/presentation/screens/settings_screens.dart';

void main() {
  testWidgets('enabling MFA displays setup secret', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformAuthApiProvider.overrideWithValue(_FakePlatformAuthApi()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SecuritySettingsScreen()),
        ),
      ),
    );

    await tester.ensureVisible(find.byType(Switch).first);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('BASE32SECRET'), findsOneWidget);
  });

  testWidgets('verifies MFA setup code', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          platformAuthApiProvider.overrideWithValue(_FakePlatformAuthApi()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SecuritySettingsScreen()),
        ),
      ),
    );

    await tester.ensureVisible(find.byType(Switch).first);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    final codeField = find.byKey(const Key('mfa-code-field'));
    await tester.scrollUntilVisible(
      codeField,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(codeField, '123456');
    final verifyButton = find.byKey(const Key('mfa-verify-button'));
    await tester.scrollUntilVisible(
      verifyButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    // 폭(뷰포트)에 따라 버튼이 fold 경계에 걸려 중심 탭이 빗나갈 수 있어
    // 완전히 보이도록 보정한 뒤 탭한다.
    await tester.ensureVisible(verifyButton);
    await tester.pumpAndSettle();
    await tester.tap(verifyButton);
    await tester.pumpAndSettle();

    expect(find.text('MFA 인증이 완료되었습니다.'), findsOneWidget);
    expect(find.text('ABCD-EFGH'), findsOneWidget);
  });
}

class _FakePlatformAuthApi extends PlatformAuthApi {
  _FakePlatformAuthApi() : super(Dio());

  @override
  Future<MfaSetupResult> setupMfa() async {
    return const MfaSetupResult(
      otpAuthUri: 'otpauth://totp/Synapse:user@example.com',
      secret: 'BASE32SECRET',
    );
  }

  @override
  Future<bool> verifyMfa(String code) async => code == '123456';

  @override
  Future<List<String>> generateMfaBackupCodes() async {
    return const ['ABCD-EFGH', 'IJKL-MNOP'];
  }
}
