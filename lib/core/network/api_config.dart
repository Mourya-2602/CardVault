enum AppEnvironment { dev, staging, prod }

class ApiConfig {
  const ApiConfig({required this.environment, required this.baseUrl});

  factory ApiConfig.fromEnvironment() {
    const environmentName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'dev',
    );
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

    final environment = switch (environmentName) {
      'staging' => AppEnvironment.staging,
      'prod' => AppEnvironment.prod,
      _ => AppEnvironment.dev,
    };

    final defaultBaseUrl = switch (environment) {
      AppEnvironment.dev => 'http://localhost:3000',
      AppEnvironment.staging => 'https://staging-api.cardvault.example',
      AppEnvironment.prod => 'https://api.cardvault.example',
    };

    return ApiConfig(
      environment: environment,
      baseUrl: configuredBaseUrl.isEmpty ? defaultBaseUrl : configuredBaseUrl,
    );
  }

  final AppEnvironment environment;
  final String baseUrl;
}
