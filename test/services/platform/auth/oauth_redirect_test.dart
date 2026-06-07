import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/platform/features/auth/data/oauth_redirect.dart';

void main() {
  test('builds provider authorization URL from base URL', () {
    final service = OAuthRedirectService(
      baseUrl: 'http://localhost:8081',
      redirect: (_) {},
    );

    expect(
      service.authorizationUri('google').toString(),
      'http://localhost:8081/oauth2/authorization/google',
    );
  });

  test('redirectToProvider sends authorization URL to redirect function', () {
    final redirectedUrls = <String>[];
    final service = OAuthRedirectService(
      baseUrl: 'http://localhost:8081',
      redirect: redirectedUrls.add,
    );

    service.redirectToProvider('github');

    expect(redirectedUrls, [
      'http://localhost:8081/oauth2/authorization/github',
    ]);
  });
}
