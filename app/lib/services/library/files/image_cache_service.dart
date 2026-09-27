import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Caches remote images to disk.
///
/// For production apps with large image sets, consider using
/// `cached_network_image` instead. This service is zero-dependency.
class ImageCacheService {
  Directory? _cacheDir;

  String get name => 'ImageCacheService';
  bool get isAvailable => _cacheDir != null;
  Future<bool> healthCheck() async => _cacheDir != null;

  Future<void> initialize() async {
    final base = await getApplicationCacheDirectory();
    _cacheDir = Directory('${base.path}${Platform.pathSeparator}images');
    await _cacheDir!.create(recursive: true);
  }

  Future<void> dispose() async { _cacheDir = null; }

  String _key(String url) =>
      url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').substring(
            url.length > 100 ? url.length - 100 : 0,
          );

  /// Returns cached file for [url], downloading if not present.
  Future<File?> get(String url, {Duration? maxAge}) async {
    if (_cacheDir == null) return null;
    final file = File('${_cacheDir!.path}${Platform.pathSeparator}${_key(url)}');
    if (await file.exists()) {
      if (maxAge != null) {
        final stat = await file.stat();
        if (DateTime.now().difference(stat.modified) > maxAge) {
          await file.delete();
        } else {
          return file;
        }
      } else {
        return file;
      }
    }
    return _download(url, file);
  }

  Future<File?> _download(String url, File dest) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await dest.writeAsBytes(response.bodyBytes, flush: true);
        return dest;
      }
    } catch (_) {}
    return null;
  }

  Future<void> clear() async {
    if (_cacheDir != null && await _cacheDir!.exists()) {
      await for (final f in _cacheDir!.list()) {
        await f.delete();
      }
    }
  }

  Future<int> sizeBytes() async {
    if (_cacheDir == null) return 0;
    var total = 0;
    await for (final f in _cacheDir!.list()) {
      if (f is File) total += await f.length();
    }
    return total;
  }
}
