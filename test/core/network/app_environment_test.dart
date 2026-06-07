import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/network/app_environment.dart';

void main() {
  group('resolveApiBaseUrl', () {
    test('override 없으면 환경 기본 baseUrl로 폴백', () {
      expect(resolveApiBaseUrl(AppEnvironment.dev), 'http://localhost:8080');
      expect(resolveApiBaseUrl(AppEnvironment.staging),
          'https://api-staging.synapse.app');
      expect(resolveApiBaseUrl(AppEnvironment.prod), 'https://api.synapse.app');
    });

    test('빈 문자열 override = 동일 오리진 상대경로', () {
      expect(resolveApiBaseUrl(AppEnvironment.prod, apiBaseOverride: ''), '');
    });

    test('비어있지 않은 override가 환경 기본값보다 우선', () {
      expect(
        resolveApiBaseUrl(AppEnvironment.dev,
            apiBaseOverride: 'https://custom.example'),
        'https://custom.example',
      );
    });
  });
}
