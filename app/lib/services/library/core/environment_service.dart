/// Runtime environment detection.
enum Env { development, test, production }

/// Determines and exposes the current runtime environment.
///
/// Resolution order:
/// 1. `CAMBRIC_ENV` compile-time constant
/// 2. Constructor argument
/// 3. Default: production
class EnvironmentService {
  final Env _env;

  EnvironmentService({Env env = Env.production}) : _env = env;

  factory EnvironmentService.fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'development': case 'dev': return EnvironmentService(env: Env.development);
      case 'test': return EnvironmentService(env: Env.test);
      default: return EnvironmentService(env: Env.production);
    }
  }

  factory EnvironmentService.fromSystem() {
    // ignore: do_not_use_environment
    const raw = String.fromEnvironment('CAMBRIC_ENV', defaultValue: 'production');
    return EnvironmentService.fromString(raw);
  }

  String get name => 'EnvironmentService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Env get environment => _env;
  bool get isDevelopment => _env == Env.development;
  bool get isTest => _env == Env.test;
  bool get isProduction => _env == Env.production;

  @override
  String toString() => _env.name;
}
