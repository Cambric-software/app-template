import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Generic resource file cache (JSON, fonts, config, etc).
class ResourceCacheService {
  Directory? _cacheDir;

  String get name => 'ResourceCacheService';
  bool get isAvailable => _cacheDir != null;
  Future<bool> healthCheck() async => _cacheDir != null;

  Future<void> initialize({String namespace = 'resources'}) async {
    final base = await getApplicationCacheDirectory();
    _cacheDir = Directory('${base.path}${Platform.pathSeparator}$namespace');
    await _cacheDir!.create(recursive: true);
  }

  Future<void> dispose() async { _cacheDir = null; }

  Future<File?> get(String key) async {
    if (_cacheDir == null) return null;
    final file = _fileFor(key);
    return await file.exists() ? file : null;
  }

  Future<File> put(String key, List<int> bytes) async {
    final file = _fileFor(key);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<File?> download(String url, String key, {bool overwrite = false}) async {
    if (_cacheDir == null) return null;
    final file = _fileFor(key);
    if (!overwrite && await file.exists()) return file;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      }
    } catch (_) {}
    return null;
  }

  Future<void> delete(String key) async {
    final file = _fileFor(key);
    if (await file.exists()) await file.delete();
  }

  Future<void> clear() async {
    if (_cacheDir != null) {
      await for (final f in _cacheDir!.list()) { await f.delete(); }
    }
  }

  File _fileFor(String key) {
    final safe = key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');
    return File('${_cacheDir!.path}${Platform.pathSeparator}$safe');
  }
}
