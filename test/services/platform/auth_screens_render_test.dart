import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/theme/app_theme.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';

// 인증 화면(로그인/회원가입/MFA/비밀번호 재설정/OAuth 동의/콜백) reskin 후
// 데스크탑/모바일 렌더 검증. 각 화면은 자체 Scaffold를 가지므로 home에 직접 둔다.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(data: MediaQueryData(size: size), child: child),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  }

  const desktop = Size(1440, 900);
  const mobile = Size(390, 844);

  for (final entry in <String, Widget>{
    'LoginScreen': const LoginScreen(),
    'SignupScreen': const SignupScreen(),
    'MfaScreen': const MfaScreen(),
    'PasswordResetScreen': const PasswordResetScreen(),
    'OAuthConsentScreen': const OAuthConsentScreen(),
  }.entries) {
    testWidgets('${entry.key} 데스크탑 렌더', (tester) async {
      await pump(tester, entry.value, desktop);
    });
    testWidgets('${entry.key} 모바일 렌더', (tester) async {
      await pump(tester, entry.value, mobile);
    });
  }
}
