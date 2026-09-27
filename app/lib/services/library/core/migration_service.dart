/// Base class for a single schema migration step.
abstract class SchemaMigration {
  final int fromVersion;
  final int toVersion;
  const SchemaMigration({required this.fromVersion, required this.toVersion});
  Future<Map<String, dynamic>> migrate(Map<String, dynamic> data);
}

/// Runs sequential versioned migrations on a data map.
///
/// Usage:
/// ```dart
/// class V1ToV2 extends SchemaMigration {
///   V1ToV2() : super(fromVersion: 1, toVersion: 2);
///
///   @override
///   Future<Map<String, dynamic>> migrate(data) async =>
///       {...data, 'newField': 'default'};
/// }
///
/// final service = MigrationService(
///   versionKey: 'schemaVersion',
///   migrations: [V1ToV2()],
/// );
/// final result = await service.run(data, targetVersion: 2);
/// ```
class MigrationService {
  final String versionKey;
  final List<SchemaMigration> _migrations;

  MigrationService({
    required this.versionKey,
    List<SchemaMigration> migrations = const [],
  }) : _migrations = List.unmodifiable(migrations);

  String get name => 'MigrationService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<Map<String, dynamic>> run(
    Map<String, dynamic> data, {
    required int targetVersion,
  }) async {
    var current = Map<String, dynamic>.from(data);
    var version = (data[versionKey] as num?)?.toInt() ?? 0;

    if (version >= targetVersion) return current;

    for (final migration in _migrations) {
      if (migration.fromVersion != version) continue;
      if (migration.toVersion > targetVersion) break;
      current = await migration.migrate(current);
      current[versionKey] = migration.toVersion;
      version = migration.toVersion;
    }

    return current;
  }
}
