/// Status of a single health check.
enum HealthStatus { ok, degraded, failed, unknown }

/// Result of a single subsystem health check.
class HealthCheckResult {
  final String subsystem;
  final HealthStatus status;
  final String? message;
  final Duration? responseTime;
  final DateTime checkedAt;

  const HealthCheckResult({
    required this.subsystem,
    required this.status,
    this.message,
    this.responseTime,
    required this.checkedAt,
  });

  bool get isHealthy => status == HealthStatus.ok;

  @override
  String toString() {
    final rt = responseTime != null ? ' (${responseTime!.inMilliseconds}ms)' : '';
    final msg = message != null ? ': $message' : '';
    return '${subsystem.padRight(24)} ${status.name.toUpperCase()}$rt$msg';
  }
}

/// Full health report across all registered subsystems.
class HealthReport {
  final List<HealthCheckResult> results;
  final DateTime generatedAt;

  const HealthReport({required this.results, required this.generatedAt});

  bool get allHealthy => results.every((r) => r.isHealthy);
  int get failedCount => results.where((r) => !r.isHealthy).length;

  List<HealthCheckResult> get failures =>
      results.where((r) => !r.isHealthy).toList();

  @override
  String toString() {
    final lines = results.map((r) => '  $r').join('\n');
    final overall = allHealthy ? 'ALL OK' : '$failedCount DEGRADED/FAILED';
    return 'Health Report [$overall]\n$lines';
  }
}

/// Registers subsystems and runs health checks against all of them.
///
/// Usage:
/// ```dart
/// final health = HealthCheckService();
/// health.register('storage', () async => LocalStorage.instance.contains('ping'));
/// health.register('network', () async => await connectivity.check() == ConnectivityState.online);
///
/// final report = await health.checkAll();
/// print(report);
/// ```
class HealthCheckService {
  final Map<String, Future<bool> Function()> _checks = {};

  String get name => 'HealthCheckService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async { _checks.clear(); }
  Future<bool> healthCheck() async => true;

  /// Registers a named health check.
  void register(String subsystem, Future<bool> Function() check) {
    _checks[subsystem] = check;
  }

  /// Removes a health check by name.
  void unregister(String subsystem) => _checks.remove(subsystem);

  /// Runs all registered checks and returns a full [HealthReport].
  Future<HealthReport> checkAll() async {
    final results = <HealthCheckResult>[];

    for (final entry in _checks.entries) {
      final start = DateTime.now();
      HealthStatus status;
      String? message;

      try {
        final ok = await entry.value().timeout(const Duration(seconds: 5));
        status = ok ? HealthStatus.ok : HealthStatus.degraded;
      } catch (e) {
        status = HealthStatus.failed;
        message = e.toString();
      }

      results.add(HealthCheckResult(
        subsystem: entry.key,
        status: status,
        message: message,
        responseTime: DateTime.now().difference(start),
        checkedAt: DateTime.now(),
      ));
    }

    return HealthReport(results: results, generatedAt: DateTime.now());
  }

  /// Runs a single named check, or returns [HealthStatus.unknown] if not registered.
  Future<HealthCheckResult> checkOne(String subsystem) async {
    final check = _checks[subsystem];
    if (check == null) {
      return HealthCheckResult(
        subsystem: subsystem,
        status: HealthStatus.unknown,
        message: 'Not registered',
        checkedAt: DateTime.now(),
      );
    }

    final start = DateTime.now();
    try {
      final ok = await check().timeout(const Duration(seconds: 5));
      return HealthCheckResult(
        subsystem: subsystem,
        status: ok ? HealthStatus.ok : HealthStatus.degraded,
        responseTime: DateTime.now().difference(start),
        checkedAt: DateTime.now(),
      );
    } catch (e) {
      return HealthCheckResult(
        subsystem: subsystem,
        status: HealthStatus.failed,
        message: e.toString(),
        responseTime: DateTime.now().difference(start),
        checkedAt: DateTime.now(),
      );
    }
  }
}
