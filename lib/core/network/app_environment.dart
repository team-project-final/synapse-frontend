enum AppEnvironment { dev, platformDev, demo, staging, prod }

AppEnvironment parseAppEnvironment(String value) {
  return switch (value) {
    'platform-dev' => AppEnvironment.platformDev,
    'demo' => AppEnvironment.demo,
    'prod' => AppEnvironment.prod,
    'staging' => AppEnvironment.staging,
    _ => AppEnvironment.dev,
  };
}

extension AppEnvironmentBaseUrl on AppEnvironment {
  String get baseUrl {
    return switch (this) {
      AppEnvironment.dev || AppEnvironment.demo => 'http://localhost:8080',
      AppEnvironment.platformDev => 'http://localhost:8081',
      AppEnvironment.staging => 'https://api-staging.synapse.app',
      AppEnvironment.prod => 'https://api.synapse.app',
    };
  }

  String get aiBaseUrl {
    return switch (this) {
      AppEnvironment.dev ||
      AppEnvironment.platformDev ||
      AppEnvironment.demo => 'http://localhost:8090',
      AppEnvironment.staging => 'https://api-staging.synapse.app',
      AppEnvironment.prod => 'https://api.synapse.app',
    };
  }

  bool get usesDemoIdentity => this == AppEnvironment.demo;

  String? get demoUserId => usesDemoIdentity ? 'mock_user_123' : null;
}

/// 효과적인 API base URL을 결정한다.
///
/// [apiBaseOverride]가 null이 아니면 우선 적용한다. 빈 문자열('')은
/// "동일 오리진 상대경로"를 의미하며, gateway가 SPA와 /api를 같은 오리진에서
/// 서빙할 때 사용한다(빌드 시 --dart-define=API_BASE_URL=). null이면 환경 기본값.
String resolveApiBaseUrl(AppEnvironment env, {String? apiBaseOverride}) {
  return apiBaseOverride ?? env.baseUrl;
}
