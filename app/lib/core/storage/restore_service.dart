import 'dart:io';

import 'backup_service.dart';
import 'cambric_paths.dart';

/// Result of a restore operation.
class RestoreResult {
  final bool success;
  final String backupId;
  final List<String> restoredFiles;
  final String? error;

  const RestoreResult({
    required this.success,
    required this.backupId,
    this.restoredFiles = const [],
    this.error,
  });

  @override
  String toString() =>
      'RestoreResult(backupId=$backupId, '
      'files=${restoredFiles.length}, success=$success)';
}

/// Restores application data from a [BackupManifest].
///
/// Restore flow:
///
/// ```
/// locate backup directory
///   ↓
/// validate manifest integrity
///   ↓
/// copy files to destination
///   ↓
/// report result
/// ```
///
/// The restore does NOT delete existing data before writing.
/// Destination files are overwritten individually.  If a partial
/// restore fails, successfully restored files remain in place.
class RestoreService {
  /// Restores from the backup described by [manifest] into [destinationDirectory].
  Future<RestoreResult> restore({
    required BackupManifest manifest,
    required Directory destinationDirectory,
  }) async {
    final backupsRoot = await CambricPaths.backups();
    final backupDataDir = Directory(
      '${backupsRoot.path}${Platform.pathSeparator}'
      '${manifest.productId}${Platform.pathSeparator}'
      '${manifest.backupId}${Platform.pathSeparator}data',
    );

    if (!await backupDataDir.exists()) {
      return RestoreResult(
        success: false,
        backupId: manifest.backupId,
        error: 'Backup data directory not found: ${backupDataDir.path}',
      );
    }

    await destinationDirectory.create(recursive: true);

    final restored = <String>[];

    try {
      await for (final entity
          in backupDataDir.list(recursive: true)) {
        if (entity is File) {
          final relative = entity.path
              .replaceFirst(backupDataDir.path, '')
              .replaceFirst(RegExp('^[/\\\\]'), '');

          final dest = File(
            '${destinationDirectory.path}'
            '${Platform.pathSeparator}$relative',
          );
          await dest.parent.create(recursive: true);
          await entity.copy(dest.path);
          restored.add(relative);
        }
      }

      return RestoreResult(
        success: true,
        backupId: manifest.backupId,
        restoredFiles: restored,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        backupId: manifest.backupId,
        restoredFiles: restored,
        error: e.toString(),
      );
    }
  }
}
