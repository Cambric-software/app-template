/// Cambric reusable service.
///
/// This service is intentionally lightweight and optional.
/// Delete it when a project does not need it.
class DataMigrationService {
  const DataMigrationService();

  /// Human-readable service identifier.
  String get name => 'DataMigrationService';

  /// Whether this service is currently available.
  bool get isAvailable => true;

  /// Initializes the service.
  Future<void> initialize() async {}

  /// Performs service cleanup.
  Future<void> dispose() async {}

  /// Generic health check.
  Future<bool> healthCheck() async => true;
}
