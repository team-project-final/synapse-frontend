enum AppEnvironment { dev, platformDev, staging, prod }

AppEnvironment parseAppEnvironment(String value) {
  return switch (value) {
    'platform-dev' => AppEnvironment.platformDev,
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
}
