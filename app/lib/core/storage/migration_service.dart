/// A single versioned migration step.
///
/// Implement [Migration] for each schema version transition:
///
/// ```dart
/// class V1ToV2Migration extends Migration {
///   V1ToV2Migration() : super(fromVersion: 1, toVersion: 2);
///
///   @override
///   Future<Map<String, dynamic>> migrate(Map<String, dynamic> data) async {
///     // Add new field with default, rename old field, etc.
///     return {...data, 'newField': 'defaultValue'};
///   }
/// }
/// ```
abstract class Migration {
  final int fromVersion;
  final int toVersion;

  const Migration({
    required this.fromVersion,
    required this.toVersion,
  });

  /// Applies this migration step to [data] and returns the migrated result.
  Future<Map<String, dynamic>> migrate(Map<String, dynamic> data);
}

/// Result of a migration run.
class MigrationResult {
  final bool migrated;
  final int fromVersion;
  final int toVersion;
  final List<String> appliedSteps;
  final String? error;

  const MigrationResult({
    required this.migrated,
    required this.fromVersion,
    required this.toVersion,
    this.appliedSteps = const [],
    this.error,
  });

  bool get succeeded => error == null;

  @override
  String toString() =>
      'MigrationResult(v$fromVersion→v$toVersion, '
      'steps=${appliedSteps.length}, succeeded=$succeeded)';
}

/// Runs sequential versioned migrations on a data map.
///
/// Register all [Migration] steps in ascending [fromVersion] order.
/// [run] will apply every step needed to bring [data] from its current
/// version up to [targetVersion].
///
/// Example:
///
/// ```dart
/// final service = MigrationService(
///   versionKey: 'schemaVersion',
///   migrations: [V1ToV2Migration(), V2ToV3Migration()],
/// );
///
/// final result = await service.run(data, targetVersion: 3);
/// ```
class MigrationService {
  final String versionKey;
  final List<Migration> _migrations;

  MigrationService({
    required this.versionKey,
    List<Migration> migrations = const [],
  }) : _migrations = List.unmodifiable(migrations);

  /// Migrates [data] to [targetVersion].
  ///
  /// If the data is already at [targetVersion], returns immediately without
  /// modification.  Never downgrades.
  Future<MigrationResult> run(
    Map<String, dynamic> data, {
    required int targetVersion,
  }) async {
    final currentVersion =
        (data[versionKey] as num?)?.toInt() ?? 0;

    if (currentVersion >= targetVersion) {
      return MigrationResult(
        migrated: false,
        fromVersion: currentVersion,
        toVersion: currentVersion,
      );
    }

    var current = Map<String, dynamic>.from(data);
    var version = currentVersion;
    final applied = <String>[];

    for (final migration in _migrations) {
      if (migration.fromVersion < version) continue;
      if (migration.fromVersion > targetVersion - 1) break;
      if (migration.fromVersion != version) continue;

      try {
        current = await migration.migrate(current);
        current[versionKey] = migration.toVersion;
        applied.add('v${migration.fromVersion}→v${migration.toVersion}');
        version = migration.toVersion;
      } catch (e) {
        return MigrationResult(
          migrated: applied.isNotEmpty,
          fromVersion: currentVersion,
          toVersion: version,
          appliedSteps: applied,
          error: e.toString(),
        );
      }
    }

    return MigrationResult(
      migrated: applied.isNotEmpty,
      fromVersion: currentVersion,
      toVersion: version,
      appliedSteps: applied,
    );
  }
}
