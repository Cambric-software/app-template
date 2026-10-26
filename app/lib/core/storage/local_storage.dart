import 'dart:convert';
import 'dart:io';

import 'atomic_file_service.dart';
import 'cambric_paths.dart';

/// Persistent key/value file storage for non-sensitive application data.
///
/// Each key is stored as a separate JSON file under
/// `Cambric/Products/<productId>/Data/`. This keeps individual reads/writes
/// cheap and avoids locking a single shared database file.
///
/// Data stored here is USER DATA - it is NEVER cleared with cache.
/// Use [CacheService] for disposable data.
///
/// Usage:
///
/// ```dart
/// final storage = LocalStorage(productId: 'my-product');
/// await storage.write('settings', {'theme': 'dark'});
/// final settings = await storage.read('settings');
/// ```
class LocalStorage {
  /// Creates storage scoped to [productId].
  LocalStorage({required this.productId});

  /// Product whose data directory is used.
  final String productId;

  final AtomicFileService _atomic = AtomicFileService();

  /// Directory where this product's user data lives.
  Future<Directory> get dataDirectory =>
      CambricPaths.productData(productId);

  Future<File> _file(String key) async {
    _validateKey(key);
    final dir = await dataDirectory;
    return File(
      '${dir.path}${Platform.pathSeparator}${_sanitizeKey(key)}.json',
    );
  }

  /// Writes [value] under [key] using an atomic write.
  Future<void> write(String key, Object? value) async {
    final file = await _file(key);
    await _atomic.write(file, jsonEncode(value));
  }

  /// Reads the value stored under [key], or `null` if absent.
  Future<dynamic> read(String key) async {
    final file = await _file(key);

    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;
      return jsonDecode(content);
    } on FormatException {
      // Corrupt file - treat as missing.
      return null;
    }
  }

  /// Returns `true` if a value exists for [key].
  Future<bool> contains(String key) async {
    final file = await _file(key);
    return file.exists();
  }

  /// Deletes the value stored under [key]. No-op if absent.
  Future<void> delete(String key) async {
    final file = await _file(key);
    if (await file.exists()) await file.delete();
  }

  /// Returns all keys currently stored.
  Future<List<String>> keys() async {
    final dir = await dataDirectory;
    final result = <String>[];

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        final name = entity.uri.pathSegments.last;
        result.add(name.replaceAll(RegExp(r'\.json$'), ''));
      }
    }

    return result;
  }

  /// Clears all stored values.
  ///
  /// WARNING: This deletes persistent user data. Only call this when the user
  /// explicitly requests a data reset, not when clearing cache.
  Future<void> clear() async {
    final dir = await dataDirectory;
    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        await entity.delete();
      }
    }
  }

  void _validateKey(String key) {
    if (key.trim().isEmpty) {
      throw ArgumentError('Storage key must not be empty.');
    }
  }

  String _sanitizeKey(String key) =>
      key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');
}
