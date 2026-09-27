import 'dart:io';

/// Creates and manages temporary files with automatic cleanup.
class TemporaryFileService {
  final Set<String> _tracked = {};

  String get name => 'TemporaryFileService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async => cleanup();
  Future<bool> healthCheck() async => true;

  Future<File> create({String prefix = 'cambric_tmp_', String suffix = ''}) async {
    final name = '$prefix${DateTime.now().millisecondsSinceEpoch}$suffix';
    final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}$name');
    await file.create();
    _tracked.add(file.path);
    return file;
  }

  Future<Directory> createDir({String prefix = 'cambric_tmp_'}) async {
    final name = '$prefix${DateTime.now().millisecondsSinceEpoch}';
    final dir = Directory('${Directory.systemTemp.path}${Platform.pathSeparator}$name');
    await dir.create();
    return dir;
  }

  Future<void> delete(File file) async {
    _tracked.remove(file.path);
    if (await file.exists()) await file.delete();
  }

  Future<void> cleanup() async {
    for (final path in List.of(_tracked)) {
      try { final f = File(path); if (await f.exists()) await f.delete(); } catch (_) {}
    }
    _tracked.clear();
  }
}
