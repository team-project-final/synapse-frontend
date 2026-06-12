enum AppEnvironment { dev, platformDev, staging, prod }

AppEnvironment parseAppEnvironment(String value) {
  return switch (value) {
    // 표기 실수로 dev(게이트웨이 8080)로 조용히 fallback돼 전 API가 죽는
    // 사고를 막기 위해 camelCase 표기도 함께 허용한다.
    'platform-dev' || 'platformDev' => AppEnvironment.platformDev,
    'prod' => AppEnvironment.prod,
    'staging' => AppEnvironment.staging,
    _ => AppEnvironment.dev,
  };
}

extension AppEnvironmentBaseUrl on AppEnvironment {
  String get baseUrl {
    return switch (this) {
      AppEnvironment.dev => 'http://localhost:8080',
      AppEnvironment.platformDev => 'http://localhost:8081',
      AppEnvironment.staging => 'https://api-staging.synapse.app',
      AppEnvironment.prod => 'https://api.synapse.app',
    };
  }

  String get aiBaseUrl {
    return switch (this) {
      AppEnvironment.dev || AppEnvironment.platformDev => 'http://localhost:8090',
      AppEnvironment.staging => 'https://api-staging.synapse.app',
      AppEnvironment.prod => 'https://api.synapse.app',
    };
  }

  String get learningBaseUrl {
    return switch (this) {
      AppEnvironment.dev || AppEnvironment.platformDev => 'http://localhost:8084',
      AppEnvironment.staging => 'https://api-staging.synapse.app',
      AppEnvironment.prod => 'https://api.synapse.app',
    };
  }
}
