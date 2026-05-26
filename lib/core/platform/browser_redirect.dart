import 'package:synapse_frontend/core/platform/browser_redirect_stub.dart'
    if (dart.library.html) 'package:synapse_frontend/core/platform/browser_redirect_web.dart'
    as browser_redirect;

void redirectToUrl(String url) {
  browser_redirect.redirectToUrl(url);
}
