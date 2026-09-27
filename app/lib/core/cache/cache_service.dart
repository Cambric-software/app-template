import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'cache_entry_metadata.dart';

/// Disk-based cache with TTL, size limits, and per-entry metadata.
///
/// Cache data is DISPOSABLE.  Clearing the cache must never delete user data.
/// User data belongs in [LocalStorage], not here.
///
/// Usage:
///
/// ```dart
/// final cache = CacheService.instance;
///
/// // Download and cache a file.
/// final file = await cache.download('https://example.com/data.zip', 'data.zip');
///
/// // Check if a cached entry is still valid.
/// if (await cache.isValid('data.zip', maxAge: Duration(hours: 24))) { ... }
///
/// // Store raw bytes.
/// await cache.saveBytes('icon.png', bytes);
/// ```
class CacheService {
  static final CacheService instance = CacheService._();

  CacheService._();

  /// Maximum total cache size in bytes.  Default: 500 MB.
  int maxSizeBytes = 500 * 1024 * 1024;

  Future<Directory> get _cacheDirectory async {
    final base = await getApplicationCacheDirectory();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}cambric_cache',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> get _metaDirectory async {
    final base = await _cacheDirectory;
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}.meta',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _file(String key) async {
    final dir = await _cacheDirectory;
    return File('${dir.path}${Platform.pathSeparator}$key');
  }

  Future<File> _metaFile(String key) async {
    final dir = await _metaDirectory;
    return File('${dir.path}${Platform.pathSeparator}$key.meta.json');
  }

  // ── entry management ─────────────────────────────────────────────────────

  /// Returns `true` if [key] exists on disk.
  Future<bool> exists(String key) async =>
      (await _file(key)).exists();

  /// Returns `true` if [key] exists AND its TTL has not expired.
  Future<bool> isValid(String key, {Duration? maxAge}) async {
    if (!await exists(key)) return false;
    if (maxAge == null) return true;

    final meta = await _readMeta(key);
    if (meta == null) return false;

    final age = DateTime.now().difference(meta.cachedAt);
    return age <= maxAge;
  }

  /// Returns the cached [File] for [key], or `null` if absent.
  Future<File?> get(String key) async {
    final file = await _file(key);
    if (!await file.exists()) return null;
    await _updateLastAccessed(key);
    return file;
  }

  /// Saves raw [bytes] under [key].
  Future<File> saveBytes(String key, List<int> bytes) async {
    final file = await _file(key);
    await file.writeAsBytes(bytes, flush: true);
    await _writeMeta(
      key,
      CacheEntryMetadata(
        key: key,
        cachedAt: DateTime.now(),
        sizeBytes: bytes.length,
      ),
    );
    return file;
  }

  /// Saves [content] as UTF-8 text under [key].
  Future<File> saveString(String key, String content) async {
    final bytes = utf8.encode(content);
    return saveBytes(key, bytes);
  }

  /// Downloads [url] and caches it under [key].
  ///
  /// Returns the cached file.  If the file already exists and
  /// [overwrite] is `false`, returns the existing file.
  Future<File> download(
    String url,
    String key, {
    bool overwrite = false,
    Duration? maxAge,
  }) async {
    if (!overwrite && await isValid(key, maxAge: maxAge)) {
      return (await get(key))!;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Cache download failed: HTTP ${response.statusCode}.',
      );
    }

    return saveBytes(key, response.bodyBytes);
  }

  /// Deletes the cached entry for [key].
  Future<void> delete(String key) async {
    final file = await _file(key);
    final meta = await _metaFile(key);
    if (await file.exists()) await file.delete();
    if (await meta.exists()) await meta.delete();
  }

  /// Removes all entries whose TTL exceeds [maxAge].
  Future<int> evictExpired(Duration maxAge) async {
    final dir = await _cacheDirectory;
    var removed = 0;

    await for (final entity in dir.list()) {
      if (entity is File &&
          !entity.path.contains('.meta')) {
        final key = entity.uri.pathSegments.last;
        if (!await isValid(key, maxAge: maxAge)) {
          await delete(key);
          removed++;
        }
      }
    }

    return removed;
  }

  /// Clears the entire cache.
  ///
  /// Safe: this ONLY removes files in the cache directory,
  /// never user data from [LocalStorage].
  Future<void> clear() async {
    final dir = await _cacheDirectory;
    if (!await dir.exists()) return;
    await dir.delete(recursive: true);
    await dir.create(recursive: true);
  }

  /// Returns the total cache size in bytes.
  Future<int> sizeBytes() async {
    final dir = await _cacheDirectory;
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// Returns the number of cached entries (excluding metadata).
  Future<int> entryCount() async {
    final dir = await _cacheDirectory;
    if (!await dir.exists()) return 0;
    var count = 0;
    await for (final entity in dir.list()) {
      if (entity is File && !entity.path.contains('.meta')) {
        count++;
      }
    }
    return count;
  }

  // ── metadata ──────────────────────────────────────────────────────────────

  Future<void> _writeMeta(String key, CacheEntryMetadata meta) async {
    final file = await _metaFile(key);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(meta.toJson()), flush: true);
  }

  Future<CacheEntryMetadata?> _readMeta(String key) async {
    final file = await _metaFile(key);
    if (!await file.exists()) return null;
    try {
      final raw = await file.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CacheEntryMetadata.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateLastAccessed(String key) async {
    final existing = await _readMeta(key);
    if (existing == null) return;
    await _writeMeta(
      key,
      CacheEntryMetadata(
        key: existing.key,
        cachedAt: existing.cachedAt,
        sizeBytes: existing.sizeBytes,
        lastAccessedAt: DateTime.now(),
      ),
    );
  }
}
