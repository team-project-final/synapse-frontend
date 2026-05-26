import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/auth_repository.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/oauth_redirect.dart';
import 'package:synapse_frontend/services/platform/features/auth/presentation/screens/auth_screens.dart';

void main() {
  testWidgets('oauth buttons redirect to provider authorization URLs', (
    tester,
  ) async {
    final redirectedUrls = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          oauthRedirectServiceProvider.overrideWithValue(
            OAuthRedirectService(
              baseUrl: 'http://localhost:8081',
              redirect: redirectedUrls.add,
            ),
          ),
          authRepositoryPortProvider.overrideWith(
            (ref) => ref.watch(authRepositoryProvider),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('Google로 로그인'));
    await tester.pump();
    await tester.tap(find.text('GitHub로 로그인'));
    await tester.pump();
    await tester.tap(find.text('Apple로 로그인'));
    await tester.pump();

    expect(redirectedUrls, [
      'http://localhost:8081/oauth2/authorization/google',
      'http://localhost:8081/oauth2/authorization/github',
      'http://localhost:8081/oauth2/authorization/apple',
    ]);
  });
}
