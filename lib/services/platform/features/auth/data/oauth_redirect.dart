import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';
import 'package:synapse_frontend/core/network/dio_client.dart';
import 'package:synapse_frontend/core/platform/browser_redirect.dart';

final oauthRedirectServiceProvider = Provider<OAuthRedirectService>((ref) {
  final environment = ref.watch(environmentProvider);
  return OAuthRedirectService(
    baseUrl: environment.baseUrl,
    redirect: redirectToUrl,
  );
});

class OAuthRedirectService {
  const OAuthRedirectService({required this.baseUrl, required this.redirect});

  final String baseUrl;
  final void Function(String url) redirect;

  Uri authorizationUri(String provider) {
    return Uri.parse('$baseUrl/oauth2/authorization/$provider');
  }

  void redirectToProvider(String provider) {
    redirect(authorizationUri(provider).toString());
  }
}
