import 'dart:convert';
import 'dart:io';

import 'atomic_file_service.dart';
import 'cambric_paths.dart';

/// Metadata stored alongside each backup.
class BackupManifest {
  final String backupId;
  final String productId;
  final String version;
  final DateTime createdAt;
  final List<String> files;
  final int totalBytes;

  const BackupManifest({
    required this.backupId,
    required this.productId,
    required this.version,
    required this.createdAt,
    required this.files,
    required this.totalBytes,
  });

  Map<String, dynamic> toJson() => {
    'backupId': backupId,
    'productId': productId,
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'files': files,
    'totalBytes': totalBytes,
  };

  factory BackupManifest.fromJson(Map<String, dynamic> json) =>
      BackupManifest(
        backupId: json['backupId']?.toString() ?? '',
        productId: json['productId']?.toString() ?? '',
        version: json['version']?.toString() ?? '0.0.0',
        createdAt: DateTime.tryParse(
              json['createdAt']?.toString() ?? '',
            ) ??
            DateTime.now(),
        files: (json['files'] as List<dynamic>? ?? [])
            .whereType<String>()
            .toList(),
        totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
      );
}

/// Creates and manages versioned local backups of application data.
///
/// Backups are stored under the Cambric `Backups/` directory.
/// They are NOT cache — they are NOT cleared with cache cleanup.
///
/// Backup structure:
///
/// ```
/// Cambric/Backups/<productId>/<backupId>/
///   manifest.json
///   data/...    (copies of source files)
/// ```
class BackupService {
  final AtomicFileService _atomic = AtomicFileService();

  /// Creates a backup of all JSON files in [sourceDirectory].
  ///
  /// Returns the [BackupManifest] describing the backup.
  Future<BackupManifest> create({
    required String productId,
    required String version,
    required Directory sourceDirectory,
  }) async {
    final backupId = _generateId();
    final backupsRoot = await CambricPaths.backups();
    final backupDir = Directory(
      '${backupsRoot.path}${Platform.pathSeparator}'
      '$productId${Platform.pathSeparator}$backupId',
    );
    await backupDir.create(recursive: true);

    final dataDir = Directory(
      '${backupDir.path}${Platform.pathSeparator}data',
    );
    await dataDir.create(recursive: true);

    final backedUpFiles = <String>[];
    var totalBytes = 0;

    if (await sourceDirectory.exists()) {
      await for (final entity in sourceDirectory.list(recursive: true)) {
        if (entity is File) {
          final relative = entity.path
              .replaceFirst(sourceDirectory.path, '')
              .replaceFirst(RegExp('^[/\\\\]'), '');
          final dest = File(
            '${dataDir.path}${Platform.pathSeparator}$relative',
          );
          await dest.parent.create(recursive: true);
          await entity.copy(dest.path);
          backedUpFiles.add(relative);
          totalBytes += await entity.length();
        }
      }
    }

    final manifest = BackupManifest(
      backupId: backupId,
      productId: productId,
      version: version,
      createdAt: DateTime.now(),
      files: backedUpFiles,
      totalBytes: totalBytes,
    );

    final manifestFile = File(
      '${backupDir.path}${Platform.pathSeparator}manifest.json',
    );
    await _atomic.write(manifestFile, jsonEncode(manifest.toJson()));

    return manifest;
  }

  /// Lists all backups for [productId], sorted newest first.
  Future<List<BackupManifest>> list(String productId) async {
    final backupsRoot = await CambricPaths.backups();
    final productDir = Directory(
      '${backupsRoot.path}${Platform.pathSeparator}$productId',
    );

    if (!await productDir.exists()) return const [];

    final results = <BackupManifest>[];

    await for (final entity in productDir.list()) {
      if (entity is Directory) {
        final manifestFile = File(
          '${entity.path}${Platform.pathSeparator}manifest.json',
        );
        if (await manifestFile.exists()) {
          try {
            final raw = await manifestFile.readAsString();
            final data = jsonDecode(raw) as Map<String, dynamic>;
            results.add(BackupManifest.fromJson(data));
          } catch (_) {
            // Skip corrupt backup manifests.
          }
        }
      }
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  /// Deletes a specific backup by [backupId].
  Future<void> delete({
    required String productId,
    required String backupId,
  }) async {
    final backupsRoot = await CambricPaths.backups();
    final backupDir = Directory(
      '${backupsRoot.path}${Platform.pathSeparator}'
      '$productId${Platform.pathSeparator}$backupId',
    );
    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
    }
  }

  String _generateId() {
    final ts = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(RegExp(r'[:\.]'), '-')
        .replaceAll('T', '_');
    return 'backup_$ts';
  }
}
