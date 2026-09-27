import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Creates versioned backups of a data directory.
class BackupService {
  String get name => 'BackupService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<Directory?> create(Directory source, {String label = 'backup'}) async {
    if (!await source.exists()) return null;
    final base = await getApplicationSupportDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final dest = Directory(
      '${base.path}${Platform.pathSeparator}Backups'
      '${Platform.pathSeparator}${label}_$ts',
    );
    await dest.create(recursive: true);

    await for (final entity in source.list(recursive: true)) {
      if (entity is File) {
        final rel = entity.path
            .replaceFirst(source.path, '')
            .replaceFirst(RegExp(r'^[/\\]'), '');
        final target = File(
          '${dest.path}${Platform.pathSeparator}$rel',
        );
        await target.parent.create(recursive: true);
        await entity.copy(target.path);
      }
    }
    return dest;
  }

  Future<List<Directory>> list() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}Backups',
    );
    if (!await dir.exists()) return [];
    final dirs = <Directory>[];
    await for (final e in dir.list()) {
      if (e is Directory) dirs.add(e);
    }
    dirs.sort((a, b) => b.path.compareTo(a.path));
    return dirs;
  }
}
