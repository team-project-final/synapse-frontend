import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/shared/widgets/domain_placeholder_scaffold.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '로그인',
      domain: 'AUTH',
      screenId: 'SCR-W-AUTH-001',
      routeHint: '/login',
    );
  }
}

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '회원가입',
      domain: 'AUTH',
      screenId: 'SCR-W-AUTH-002',
      routeHint: '/signup',
    );
  }
}

class MfaScreen extends ConsumerWidget {
  const MfaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: 'MFA 검증',
      domain: 'AUTH',
      screenId: 'SCR-W-AUTH-003',
      routeHint: '/mfa',
    );
  }
}

class PasswordResetScreen extends ConsumerWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: '비밀번호 재설정',
      domain: 'AUTH',
      screenId: 'SCR-W-AUTH-004',
      routeHint: '/password-reset',
    );
  }
}

class OAuthConsentScreen extends ConsumerWidget {
  const OAuthConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DomainPlaceholderScaffold(
      title: 'OAuth 동의',
      domain: 'AUTH',
      screenId: 'SCR-W-AUTH-005',
      routeHint: '/oauth-consent',
    );
  }
}
