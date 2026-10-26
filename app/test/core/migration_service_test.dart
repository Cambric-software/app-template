import 'package:flutter_test/flutter_test.dart';
import 'package:cambric_app/core/storage/migration_service.dart';

class _AddFieldMigration extends Migration {
  _AddFieldMigration() : super(fromVersion: 1, toVersion: 2);

  @override
  Future<Map<String, dynamic>> migrate(
    Map<String, dynamic> data,
  ) async {
    return {...data, 'newField': 'defaultValue'};
  }
}

class _RenameFieldMigration extends Migration {
  _RenameFieldMigration() : super(fromVersion: 2, toVersion: 3);

  @override
  Future<Map<String, dynamic>> migrate(
    Map<String, dynamic> data,
  ) async {
    final copy = Map<String, dynamic>.from(data);
    copy['renamedField'] = copy.remove('newField');
    return copy;
  }
}

void main() {
  group('MigrationService', () {
    late MigrationService service;

    setUp(() {
      service = MigrationService(
        versionKey: 'schemaVersion',
        migrations: [
          _AddFieldMigration(),
          _RenameFieldMigration(),
        ],
      );
    });

    test('does not migrate when already at target version', () async {
      final data = {'schemaVersion': 3, 'renamedField': 'x'};
      final result = await service.run(data, targetVersion: 3);

      expect(result.migrated, isFalse);
      expect(result.fromVersion, 3);
    });

    test('applies single migration step', () async {
      final data = {'schemaVersion': 1, 'existing': 'value'};
      final result = await service.run(data, targetVersion: 2);

      expect(result.migrated, isTrue);
      expect(result.toVersion, 2);
      expect(result.appliedSteps, ['v1→v2']);
    });

    test('chains multiple migration steps', () async {
      final data = {'schemaVersion': 1, 'existing': 'value'};
      final result = await service.run(data, targetVersion: 3);

      expect(result.migrated, isTrue);
      expect(result.toVersion, 3);
      expect(result.appliedSteps, ['v1→v2', 'v2→v3']);
      expect(result.succeeded, isTrue);
    });

    test('never downgrades', () async {
      final data = {'schemaVersion': 3};
      final result = await service.run(data, targetVersion: 1);

      expect(result.migrated, isFalse);
    });
  });
}
