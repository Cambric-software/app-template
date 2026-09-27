import 'dart:io';
import 'dart:convert';

/// File read/write/copy/move operations with safety checks.
///
/// Usage:
/// ```dart
/// final fs = FileService();
/// await fs.writeText(file, 'hello world');
/// final content = await fs.readText(file);
/// await fs.copyTo(file, destination);
/// ```
class FileService {
  String get name => 'FileService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<String> readText(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('File not found', file.path);
    }
    return file.readAsString();
  }

  Future<List<int>> readBytes(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('File not found', file.path);
    }
    return file.readAsBytes();
  }

  Future<Map<String, dynamic>?> readJson(File file) async {
    final text = await readText(file);
    try {
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeText(File file, String content) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }

  Future<void> writeBytes(File file, List<int> bytes) async {
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> writeJson(File file, Map<String, dynamic> data,
      {bool pretty = false}) async {
    final encoder =
        pretty ? const JsonEncoder.withIndent('  ') : const JsonEncoder();
    await writeText(file, encoder.convert(data));
  }

  Future<File> copyTo(File source, File destination) async {
    await destination.parent.create(recursive: true);
    return source.copy(destination.path);
  }

  Future<void> move(File source, File destination) async {
    await destination.parent.create(recursive: true);
    await source.rename(destination.path);
  }

  Future<void> delete(File file) async {
    if (await file.exists()) await file.delete();
  }

  Future<bool> exists(File file) => file.exists();

  Future<int> sizeBytes(File file) async {
    if (!await file.exists()) return 0;
    return (await file.stat()).size;
  }

  /// Returns a human-readable file size string.
  String humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
