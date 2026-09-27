import 'dart:io';

/// Restores a backup directory to a destination.
class RestoreService {
  String get name => 'RestoreService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<bool> restore(Directory backup, Directory destination) async {
    if (!await backup.exists()) return false;
    await destination.create(recursive: true);

    await for (final entity in backup.list(recursive: true)) {
      if (entity is File) {
        final rel = entity.path
            .replaceFirst(backup.path, '')
            .replaceFirst(RegExp(r'^[/\\]'), '');
        final target = File(
          '${destination.path}${Platform.pathSeparator}$rel',
        );
        await target.parent.create(recursive: true);
        await entity.copy(target.path);
      }
    }
    return true;
  }
}
