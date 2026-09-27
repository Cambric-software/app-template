import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Platform-safe path resolution and manipulation.
class PathService {
  String get name => 'PathService';
  bool get isAvailable => true;
  Future<void> initialize() async {}
  Future<void> dispose() async {}
  Future<bool> healthCheck() async => true;

  Future<String> appData() async => (await getApplicationSupportDirectory()).path;
  Future<String> appCache() async => (await getApplicationCacheDirectory()).path;
  Future<String> temp() async => Directory.systemTemp.path;

  String join(String base, String part) =>
      '$base${Platform.pathSeparator}$part';

  String joinAll(List<String> parts) =>
      parts.join(Platform.pathSeparator);

  String basename(String path) {
    final sep = Platform.pathSeparator;
    return path.split(sep).last;
  }

  String dirname(String path) {
    final sep = Platform.pathSeparator;
    final parts = path.split(sep);
    if (parts.length <= 1) return '.';
    return parts.sublist(0, parts.length - 1).join(sep);
  }

  String extension(String path) {
    final base = basename(path);
    final dot = base.lastIndexOf('.');
    return dot >= 0 ? base.substring(dot) : '';
  }

  String withoutExtension(String path) {
    final ext = extension(path);
    return ext.isEmpty ? path : path.substring(0, path.length - ext.length);
  }

  bool isAbsolute(String path) =>
      path.startsWith('/') || (Platform.isWindows && RegExp(r'^[A-Za-z]:').hasMatch(path));

  String sanitize(String filename) =>
      filename.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_').replaceAll('..', '_');
}
