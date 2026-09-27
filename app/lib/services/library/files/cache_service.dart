import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// General-purpose disk cache with TTL and size tracking.
class CacheService {
  Directory? _dir;

  String get name => 'CacheService';
  bool get isAvailable => _dir != null;
  Future<bool> healthCheck() async => _dir != null;

  Future<void> initialize({String namespace = 'cache'}) async {
    final base = await getApplicationCacheDirectory();
    _dir = Directory('${base.path}${Platform.pathSeparator}$namespace');
    await _dir!.create(recursive: true);
  }

  Future<void> dispose() async { _dir = null; }

  Future<bool> exists(String key) async => (await _file(key)).exists();

  Future<bool> isValid(String key, {Duration? maxAge}) async {
    final f = await _file(key);
    if (!await f.exists()) return false;
    if (maxAge == null) return true;
    final stat = await f.stat();
    return DateTime.now().difference(stat.modified) <= maxAge;
  }

  Future<File?> get(String key) async {
    final f = await _file(key);
    return await f.exists() ? f : null;
  }

  Future<File> put(String key, List<int> bytes) async {
    final f = await _file(key);
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  Future<File> putString(String key, String content) async {
    final f = await _file(key);
    await f.writeAsString(content, flush: true);
    return f;
  }

  Future<File> download(
    String url,
    String key, {
    bool overwrite = false,
    Duration? maxAge,
  }) async {
    if (!overwrite && await isValid(key, maxAge: maxAge)) {
      return (await _file(key));
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Download failed: HTTP ${response.statusCode}');
    }
    return put(key, response.bodyBytes);
  }

  Future<void> delete(String key) async {
    final f = await _file(key);
    if (await f.exists()) await f.delete();
  }

  Future<void> clear() async {
    if (_dir != null && await _dir!.exists()) {
      await for (final e in _dir!.list()) {
        await e.delete(recursive: true);
      }
    }
  }

  Future<int> sizeBytes() async {
    if (_dir == null) return 0;
    var total = 0;
    await for (final e in _dir!.list(recursive: true)) {
      if (e is File) total += await e.length();
    }
    return total;
  }

  Future<File> _file(String key) async {
    final safe = key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');
    return File('${_dir!.path}${Platform.pathSeparator}$safe');
  }
}
