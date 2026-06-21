import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';

void main() {
  test('platform-dev maps to platform direct environment', () {
    expect(parseAppEnvironment('platform-dev'), AppEnvironment.platformDev);
    expect(AppEnvironment.platformDev.baseUrl, 'http://localhost:8081');
  });

  test('dev keeps gateway base URL', () {
    expect(parseAppEnvironment('dev'), AppEnvironment.dev);
    expect(AppEnvironment.dev.baseUrl, 'http://localhost:8080');
  });

  test('demo is the only environment that opts into mock user identity', () {
    expect(parseAppEnvironment('demo'), AppEnvironment.demo);
    expect(AppEnvironment.demo.usesDemoIdentity, isTrue);
    expect(AppEnvironment.demo.demoUserId, 'mock_user_123');

    expect(AppEnvironment.dev.usesDemoIdentity, isFalse);
    expect(AppEnvironment.staging.demoUserId, isNull);
    expect(AppEnvironment.prod.demoUserId, isNull);
  });
}
