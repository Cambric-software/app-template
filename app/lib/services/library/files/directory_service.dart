import 'dart:io';

/// Directory management operations.
class DirectoryService {
  String get name => 'DirectoryService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<Directory> ensure(Directory dir) async {
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> delete(Directory dir, {bool recursive = true}) async {
    if (await dir.exists()) await dir.delete(recursive: recursive);
  }

  Future<void> clear(Directory dir) async {
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      await entity.delete(recursive: true);
    }
  }

  Future<List<File>> listFiles(Directory dir,
      {String? extension, bool recursive = false}) async {
    if (!await dir.exists()) return [];
    final results = <File>[];
    await for (final entity in dir.list(recursive: recursive)) {
      if (entity is File) {
        if (extension == null || entity.path.endsWith(extension)) {
          results.add(entity);
        }
      }
    }
    return results;
  }

  Future<int> sizeBytes(Directory dir) async {
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  Future<void> copyTo(Directory source, Directory destination) async {
    await ensure(destination);
    await for (final entity in source.list(recursive: true)) {
      if (entity is File) {
        final relative = entity.path
            .replaceFirst(source.path, '')
            .replaceFirst(RegExp(r'^[/\\]'), '');
        final dest =
            File('${destination.path}${Platform.pathSeparator}$relative');
        await dest.parent.create(recursive: true);
        await entity.copy(dest.path);
      }
    }
  }

  Future<bool> exists(Directory dir) => dir.exists();
}
