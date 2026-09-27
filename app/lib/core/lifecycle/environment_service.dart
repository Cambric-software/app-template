/// Supported runtime environments.
enum CambricEnvironment {
  development,
  test,
  production,
}

/// Provides the current runtime environment.
///
/// The environment is determined at startup from:
/// 1. The `CAMBRIC_ENV` environment variable if present.
/// 2. The [CambricConfig] `environment` field.
/// 3. Debug/release mode as a fallback.
///
/// Use this to guard development-only behavior:
///
/// ```dart
/// if (env.isDevelopment) {
///   // show developer overlay
/// }
/// ```
class EnvironmentService {
  final CambricEnvironment _environment;

  const EnvironmentService(this._environment);

  factory EnvironmentService.fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'test':
        return const EnvironmentService(CambricEnvironment.test);
      case 'production':
      case 'prod':
        return const EnvironmentService(CambricEnvironment.production);
      case 'development':
      case 'dev':
      default:
        return const EnvironmentService(CambricEnvironment.development);
    }
  }

  /// Resolves from `CAMBRIC_ENV` environment variable, falling back to
  /// `defaultValue`.
  factory EnvironmentService.fromSystem({
    CambricEnvironment defaultValue = CambricEnvironment.development,
  }) {
    // ignore: do_not_use_environment
    const raw = String.fromEnvironment('CAMBRIC_ENV');
    if (raw.isEmpty) return EnvironmentService(defaultValue);
    return EnvironmentService.fromString(raw);
  }

  CambricEnvironment get environment => _environment;

  bool get isDevelopment => _environment == CambricEnvironment.development;
  bool get isTest => _environment == CambricEnvironment.test;
  bool get isProduction => _environment == CambricEnvironment.production;

  @override
  String toString() => _environment.name;
}
