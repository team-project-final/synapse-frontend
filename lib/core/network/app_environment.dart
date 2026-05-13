enum AppEnvironment { dev, staging, prod }

extension AppEnvironmentBaseUrl on AppEnvironment {
  String get baseUrl {
    return switch (this) {
      AppEnvironment.dev => 'http://localhost:8080',
      AppEnvironment.staging => 'https://api-staging.synapse.app',
      AppEnvironment.prod => 'https://api.synapse.app',
    };
  }
}
