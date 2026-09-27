import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CacheService {
  static final CacheService instance = CacheService._();

  CacheService._();

  Future<Directory> get _cacheDirectory async {
    final base = await getApplicationCacheDirectory();

    final directory = Directory(
      '${base.path}${Platform.pathSeparator}cambric_cache',
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future<File> _file(String key) async {
    final directory = await _cacheDirectory;

    return File(
      '${directory.path}${Platform.pathSeparator}$key',
    );
  }

  Future<bool> exists(String key) async {
    return (await _file(key)).exists();
  }

  Future<File?> get(String key) async {
    final file = await _file(key);

    if (!await file.exists()) {
      return null;
    }

    return file;
  }

  Future<File> saveBytes(String key, List<int> bytes) async {
    final file = await _file(key);

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file;
  }

  Future<File> download(
    String url,
    String key, {
    bool overwrite = false,
  }) async {
    final existing = await _file(key);

    if (!overwrite && await existing.exists()) {
      return existing;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Download failed with HTTP ${response.statusCode}.',
      );
    }

    return saveBytes(key, response.bodyBytes);
  }

  Future<void> delete(String key) async {
    final file = await _file(key);

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clear() async {
    final directory = await _cacheDirectory;

    if (!await directory.exists()) return;

    await for (final entity in directory.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

  Future<int> sizeBytes() async {
    final directory = await _cacheDirectory;

    if (!await directory.exists()) return 0;

    var total = 0;

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }

    return total;
  }
}
